$ServerName   = Read-Host -Prompt "Enter the server name"
$DateTime     = Read-Host -Prompt "Enter the date/time of the incident"
$MinuteWindow = Read-Host -Prompt "Enter the window on each side, in minutes"

$Begin = (Get-Date($DateTime)).AddMinutes(-$MinuteWindow);
$End   = (Get-Date($DateTime)).AddMinutes( $MinuteWindow);

# later if we want to pull all servers within the same WSFC, we can pull that list using Get-ClusterNode, but we likely need creds
# $cred = Get-Credential -Message "Enter your credentials:";
# $Servers = Invoke-Command -ComputerName $ServerName -ScriptBlock { Get-ClusterNode } -Credential $cred | Select Name;                                                                                                                          # | Where-Object -FilterScript {$_.Name -like 'AG_*'} } -Credential $cred;

$Servers = @($ServerName);

$Logs = @("System","Application","HardwareEvents","Microsoft-Windows-FailoverClustering-Manager/Admin",
          "Microsoft-Windows-FailoverClustering/Operational");

$Providers = @("Microsoft-Windows-FailoverClustering","Microsoft-Windows-FailoverClustering-Manager",
               "MSSQLSERVER","EventLog","Service Control Manager","nssm");

# foreach ($server in $Servers)
# {
  $events = Get-WinEvent -ComputerName $serverName -FilterHashtable @{ 
      LogName      = $Logs;
      ProviderName = $Providers; 
      StartTime    = $Begin; 
      EndTime      = $End; 
      #Level        = 1,2,3 
    } -ErrorAction Stop | 
    Where-Object {
    ($_.ProviderName -in ("MSSQLSERVER","Microsoft-Windows-FailoverClustering") -and 
       $_.Id -notin (17103,3408,46920,17177,17115,17111,17550,17135,8128,49903,17551,18100,33090) -and 
       $_.Id -notin (15268,18496,6299,3450,17136,849,26018,49904,35266,17806,18452,17101))
    } | Select-Object Id,TimeCreated,Message,LogName,ProviderName,Level,MachineName | Sort-Object Id,TimeCreated;
# }

$LastEventID = -1;
$LastLogName = [string]::empty;
$thisEventCounter = 0;
$totalEventCounter = 0;
$rowsToIgnore = @();
$EntityList = @(); 

$result = foreach ($incident in $events)
{
    $ServerName = $incident.MachineName
    $IncidentID = $incident.Id;
    $DateTime   = $incident.TimeCreated;
    $Message    = $incident.Message;
    $ErrorLevel = $incident.Level;
    $totalEventCounter += 1;

    if ($IncidentID -ne $LastEventID)
    {
        $LastEventID = $IncidentID;
        $EntityList = @(); 
        $Entity = [string]::Empty;
        $MinTime = $DateTime;
        $MaxTime = $DateTime;
        $thisEventCounter = 0;
    }
    else 
    {
        # ignore previous row
        $rowsToIgnore += $totalEventCounter - 1;
        if ($DateTime -lt $MinTime) { $MinTime = $DateTime; }
        if ($DateTime -gt $MaxTime) { $MaxTime = $DateTime; }
    }
    $thisEventCounter += 1;

    $splitElements = 3;

    if ($IncidentID -in (19406,26070,1480,19420,41061,41075,35201,3303,35206,35202) -and 
      ($Message -like '*The availability group database*' -or
       $Message -like '*availability replica*' -or 
       $Message -like '*availability database*' -or 
       $Message -like '*in database*' -or 
       $Message -like '*in availability group*' -or 
       $Message -like '*for availability group*'))
    {
        if ($IncidentID -eq 3303) { $splitElements = 5; }
        $MessageParts = $Message.Replace("'",'"')|%{$_.split('"',$splitElements)};
        $Entity = $MessageParts[$splitElements - 2];
        $EntityList += $Entity;
        if ($thisEventCounter -gt 1)
        {
            $Message = "$($MessageParts[0])<x>$($MessageParts[2])";
            if ($IncidentID -eq 3303)
            {
                $Message += "<x>$($MessageParts[4])$($MessageParts[5])"
            }
        }
    }

    $EntityList | Sort-Object Value -Unique;

    [PSCustomObject]@{
        RowNumber       = $totalEventCounter;
        EventCount      = $thisEventCounter;
        Message         = $Message;
        IncidentID      = $IncidentID;
        ServerName      = $ServerName.ToUpper();
        Source          = "$($incident.LogName) / $($incident.ProviderName)";
        FirstOccurrence = $MinTime;
        LastOccurrence  = $MaxTime;
        Level           = $ErrorLevel;
        Entities        = if ($EntityList.Count -gt 0) { $EntityList }; 
    }
}

$result | Where-Object -FilterScript {$_.RowNumber -notin $rowsToIgnore} | 
          Select Level,IncidentID,FirstOccurrence,LastOccurrence,EventCount,ServerName,Source,Message |
          Sort-Object FirstOccurrence, ServerName, -EventCount -Unique | Format-Table -AutoSize;

$result | Where-Object -FilterScript {$_.RowNumber -notin $rowsToIgnore} | 
          Select Level,IncidentID,FirstOccurrence,LastOccurrence,EventCount,ServerName,Source,Entities,Message |
          Sort-Object FirstOccurrence, ServerName, EventCount -Unique | Format-List;

$result.Initialize();
$events.Initialize();
$EntityList.Initialize();
$rowsToIgnore.Initialize();
