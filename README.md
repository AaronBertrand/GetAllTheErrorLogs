# GetAllTheErrorLogs
Powershell to assemble a timeline combining salient events from Windows Event Log, Failover Cluster log, and SQL Server errorlog.

I have a need to build timelines surrounding critical events in our environment, like an AG or FCI failover.

For example, I want to list out all of the **important** things that happened, across all three log sources, listed in chronological order. This is usually used to put into a ticket in JIRA, so it needs to be concise. For each event, first instance, last instance, and count. Today we go to each of the logs manually, find the nuggets while wading through all the noise, and piece it together ourselves.

I can get this information independently from `Get-EventLog` and `Get-SqlErrorLog`, but I want to build something more powerful that will give me the combined list in a usable format - a simple command that can take a server name, a timestamp, and a window as a starting point, and just go get me all the stuff, but leave out all the noise. We can assemble a list of event IDs we care about and event IDs we don't.

I don't have **any** code yet. But I will soon.
