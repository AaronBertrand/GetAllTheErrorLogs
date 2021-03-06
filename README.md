# GetAllTheErrorLogs
PowerShell to assemble a timeline combining salient events from Windows Event Log sources.

I have a need to build timelines surrounding critical events in our environment, like an AG or FCI failover, merging data from application, system, and failover clustering providers.

For example, I want to list out all of the **important** things that happened, across all three log sources, listed in chronological order, say 15 minutes before the event and 15 minutes after. This timeline is usually used to put into a ticket in JIRA, so it needs to be concise. For each event, show the first instance, last instance, and count. If it's something that affected multiple databases on that instance, break that down too. Today we go to each of the logs manually, find the nuggets while wading through all the noise, and piece it together ourselves.

I can certainly get this information independently from `Get-EventLog`, but I want to build something more powerful that will give me the combined list in a usable format. I envision a simple command that can take a server name, a timestamp, and a window as a starting point, and just go get me all the stuff, but leave out all the noise. We can assemble a list of event IDs we care about and event IDs we don't, and those would act as filters, but could be overridden.

The code right now is very simplistic, and there is plenty more to do. I talk a little more about it in [this T-SQL Tuesday post](https://sqlblog.org/2020/09/08/t-sql-tuesday-130-automate), which I'll keep updated as I make enhancements here.
