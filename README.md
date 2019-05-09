# NUelementsDB

This repository is for collection, cleaning, and analysis scripts used to get data from the reporting database for [Northwestern University's instance](https://elements.northwestern.edu) of [Symplectic Elements](https://symplectic.co.uk/products/elements-3/0), a research information management system. Elements uses SQL ServerThe R script _reshape_pub_source_ids.r_ is used to tidy data extracted from the database to make it easier to process.

## Some example T-SQL query templates for input to _reshape_pub_source_ids.r_

```SQL
use [Elements-reporting2]

SELECT g.name, pr.[Publication ID], doi, [Data Source], [Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE [publication-date] > YYYYMMDD AND [publication-date] <= YYYYMMDD AND g.name = 'group_name'
ORDER BY pr.[Publication ID]
```

```SQL
-- NOTE: Pubs may have duplicate publication dates, DOIs, and proprietary IDs (Scopus, ORCiD, WOS, etc.)

use [Elements-reporting2]

SELECT u.[Last Name], u.[First Name], u.[Username], u.[Department], g.[name], pr.[Publication ID], pr.[publication-date], pr.[authors], pr.[title], pr.[journal], pr.[publication-status], pr.[types], pr.[external-identifiers], pr.[doi], pr.[Data Source Proprietary ID], pr.[Data Source]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE [publication-date] > YYYYMMDD AND [publication-date] <= YYYYMMDD AND g.name = 'group_name'
ORDER BY u.[Last Name]
```

```SQL
-- NOTE: Pubs may have duplicate publication dates, DOIs, and proprietary IDs (Scopus, ORCiD, WOS, etc.)

use [Elements-reporting2]

SELECT g.name as "Group Name", u.[Last Name], u.[First Name], u.[Department], u.Username, uia.[Identifier Value] as "Scopus AU-ID", pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[User Identifier Association] as uia on uia.[User ID] = u.[ID]
join [dbo].[Identifier Scheme] as idsch on idsch.ID = uia.[Identifier Scheme ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE pr.[publication-date] > YYYYMMDD AND pr.[publication-date] <= YYYYMMDD AND g.name = 'group_name_1'
   OR pr.[publication-date] > YYYYMMDD AND pr.[publication-date] <= YYYYMMDD AND g.name = 'group_name_2'
   OR pr.[publication-date] > YYYYMMDD AND pr.[publication-date] <= YYYYMMDD AND g.name = 'group_name_3'
ORDER BY u.[Last Name]
```
