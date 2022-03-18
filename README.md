# Microsoft Sentinel 👁
## Runbooks 🧾
Contains Azure Automation runbooks for various integrations with Sentinel


### Send-LogAnalyticsData 🔍
Takes a log in JSON format, a log type and optionally a field containing the timestamp

---

### Get-UmbrellaLogs ☔
Leverages Cisco Umbrella's API to collect logs, and then uses Send-LogAnalyticsData to push these into Sentinel.