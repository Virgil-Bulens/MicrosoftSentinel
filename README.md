# Microsoft Sentinel ๐
## Runbooks ๐งพ
Contains Azure Automation runbooks for various integrations with Sentinel


### Send-LogAnalyticsData ๐
Takes a log in JSON format, a log type and optionally a field containing the timestamp

---

### Get-UmbrellaLogs โ
Leverages Cisco Umbrella's API to collect logs, and then uses Send-LogAnalyticsData to push these into Sentinel.