# GetAllTheErrorLogs
Powershell to assemble a timeline combining salient events from Windows Event Log, Failover Cluster log, and SQL Server errorlog.

I have a need to build timelines surrounding critical events in our environment, like an AG or FCI failover.

For example, I want to list out all of the **important** things that happened, across all three log sources, 

I can get this information independently from `Get-EventLog` and `Get-SqlErrorLog` but I want to build something more powerful - a simple command that can take a server name, a timestamp, and a window (say 15 minutes each side) as a starting point, and just go get me all the stuff, but leave out all the noise.

I don't have any code yet. But I will soon.
