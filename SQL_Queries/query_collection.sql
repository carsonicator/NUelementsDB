-- An example SQL query to generate a data set for reshape_pub_source_ids.r
-- All Cancer Center pubs from 2012 - present

use [Elements-reporting2]

SELECT g.name, pr.[Publication ID], doi, [Data Source], [Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE [publication-date] > 20120101 AND [publication-date] <= 20170612 AND g.name = 'RHLCCC1'
ORDER BY pr.[Publication ID]

----------------------------

-- A similar query with author and publication information
-- NOTE: Pubs may have duplicate publication dates, DOIs, and proprietary IDs (Scopus, WOS, etc.)

use [Elements-reporting2]

SELECT u.[Last Name], u.[First Name], u.[Username], u.Department, g.name, pr.[Publication ID], pr.[publication-date], pr.[authors], pr.[title], pr.[journal], pr.[publication-status], pr.[types], pr.[external-identifiers], pr.[doi], pr.[Data Source Proprietary ID], pr.[Data Source]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE [publication-date] > 20120101 AND [publication-date] <= 20170612 AND g.name = 'RHLCCC1'
ORDER BY u.[Last Name]

---------------------------

-- Querying for authors pubs when authors are in at least one of three groups
-- Also includes Scopus Author ID and Employee_ID
-- NOTE: Pubs may have duplicate publication dates, DOIs, and proprietary IDs (Scopus, WOS, etc.)

SELECT g.name as "Group Name", u.[Last Name], u.[First Name], u.[Department], u.Username, uia.[Identifier Value] as "Scopus AU-ID", pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[User Identifier Association] as uia on uia.[User ID] = u.[ID]
join [dbo].[Identifier Scheme] as idsch on idsch.ID = uia.[Identifier Scheme ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE pr.[publication-date] > 20130101 AND pr.[publication-date] <= 20171231 AND g.name = 'FAM_COM_MED_FY2018'
   OR pr.[publication-date] > 20130101 AND pr.[publication-date] <= 20171231 AND g.name = 'RADIOLOGY_FY2018'
   OR pr.[publication-date] > 20130101 AND pr.[publication-date] <= 20171231 AND g.name = 'SURGERY_FY2018'
ORDER BY u.[Last Name]
