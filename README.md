# GetAllTheErrorLogs
PowerShell to assemble a timeline combining salient events from Windows Event Log, Failover Cluster log, and SQL Server errorlog.

I have a need to build timelines surrounding critical events in our environment, like an AG or FCI failover.

For example, I want to list out all of the **important** things that happened, across all three log sources, listed in chronological order, say 15 minutes before the event and 15 minutes after. This timeline is usually used to put into a ticket in JIRA, so it needs to be concise. For each event, show the first instance, last instance, and count. If it's something that affected multiple databases on that instance, break that down too. Today we go to each of the logs manually, find the nuggets while wading through all the noise, and piece it together ourselves.

I can certainly get this information independently from `Get-EventLog` and `Get-SqlErrorLog`, but I want to build something more powerful that will give me the combined list in a usable format. I envision a simple command that can take a server name, a timestamp, and a window as a starting point, and just go get me all the stuff, but leave out all the noise. We can assemble a list of event IDs we care about and event IDs we don't, and those would act as filters, but could be overridden.

The code right now is very simplistic - it doesn't filter out duplicates, it doesn't capture all of the events I think are important, and it doesn't even touch the cluster log yet. But it gives an idea where I'm going.
