$ServerName   = Read-Host -Prompt "Enter the server name"
$DateTime     = Read-Host -Prompt "Enter the date/time of the incident"
$MinuteWindow = Read-Host -Prompt "Enter the window on each side, in minutes"

$Begin = (Get-Date($DateTime)).AddMinutes(-$MinuteWindow);
$End   = (Get-Date($DateTime)).AddMinutes( $MinuteWindow);

$Logs = @("System","Application","HardwareEvents","Microsoft-Windows-FailoverClustering-Manager/Admin");
$Providers = @("Microsoft-Windows-FailoverClustering","Microsoft-Windows-FailoverClustering-Manager","MSSQLSERVER","EventLog","Service Control Manager"); 

   Get-WinEvent -ComputerName $ServerName -FilterHashtable @{ 
      LogName      = $Logs;
      ProviderName = $Providers; 
      StartTime    = $Begin; 
      EndTime      = $End; 
      Level        = 1,2,3;
    } -ErrorAction Stop | 
    Where-Object {
        ($_.Id -in (7011,7034) -and $_.Message -match "MSSQLSERVER") -or 
        ($_.ProviderName -eq "MSSQLSERVER"             -and $_.Id -in (3314,9001,9666,11302,17053)) -or
        ($_.ProviderName -eq "Microsoft-Windows-Ntfs"  -and $_.Id -eq 140) -or
        ($_.ProviderName -eq "disk"                    -and $_.Id -eq 151) -or
        ($_.ProviderName -eq "Microsoft-Windows-FailoverClustering" -and $_.Id -in (1038,1069,1564))
    } | Select TimeCreated,Id,LogName,ProviderName,Message | Sort-Object TimeCreated | Format-List;

  Get-SqlErrorLog -ServerInstance $ServerName |#-After $($Begin) -Before $($End) | 
    Where-Object { 
      ($_.Date -gt $Begin -and $_.Date -lt $End) -and
      (
        ($_.Text -match 'chang' -and $_.Text -match 'resolving') -or 
        ($_.Text -match 'connection timeout' -and $_.Text -match 'availability group') -or 
        ($_.Text -match 'consecutive heartbeats') -or 
        ($_.Text -match 'removed from cluster membership')  -or 
        ($_.Text -match 'stop lease renewal') -or 
        ($_.Text -match 'secondary database terminated') 
      )
    } | Select Date,Text | Sort-Object Date | Format-List; 
