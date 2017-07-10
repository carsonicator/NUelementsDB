# NUelementsDB

This is a project folder for data munging/analysis scripts related to NU's Symplectic Elements database.

## SQL Query to generate data for _reshape_pub_source_ids.r_

```SQL

-- All Cancer Center pubs from 2012 - present

use [Elements-reporting2]

SELECT pu.[User ID], g.name, pr.[Publication ID], doi, [Data Source], [Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE [publication-date] > 20120101 AND [publication-date] <= 20170612 AND g.name = 'RHLCCC1'
ORDER BY pr.[Publication ID]
```