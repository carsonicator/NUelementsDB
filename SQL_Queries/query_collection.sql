-- How do I get a list of all users in alphabetical order by last name?
SELECT  u.[Last Name],
        u.[First Name],
        u.[Department],
        u.[Username] AS "NetID",
        u.[Proprietary ID] AS "Employee_ID",
        u.[Position]
FROM dbo.[User] as u
ORDER BY u.[Last Name]


-- How do I get a list of all employee position titles and the number of people who hold each, ordered from most to least?
SELECT u.[Position], count(u.[Username]) as Position_Count
FROM dbo.[User] as u
GROUP BY u.[Position]
ORDER BY Position_Count DESC


-- How do I get a list of all member of a group?
use [Elements-reporting2]

SELECT *
FROM dbo.[Group User Membership] as gu
JOIN dbo.[Group] as g
	on g.[ID] = gu.[Group ID]
WHERE  g.Name= 'group_name'


-- How do I get a list of all member of a group with the user's personal information?
use [Elements-reporting2]

SELECT  u.[Last Name],
        u.[First Name],
        u.[Department],
        u.[Username] AS "NetID",
        u.[Proprietary ID] AS "Employee_ID"
FROM dbo.[Group User Membership] as gu
JOIN dbo.[Group] as g
	on g.[ID] = gu.[Group ID]
join dbo.[User] as u
	on u.[ID] = gu.[User ID]
WHERE  g.Name= 'group_name'


-- How do I get a list of all members of a group who have one or more Scopus Author IDs?
use [Elements-reporting2]

SELECT  g.[Name] AS "Group Name",
        u.[Last Name],
        u.[First Name],
        u.[Department],
        u.[Username] AS "NetID",
        u.[Proprietary ID] AS "Employee_ID",
        idsch.[Name] AS "Author_ID_Scheme",
        uia.[Identifier Value] AS "Author_ID"

FROM    -- start with Groups
        [dbo].[Group] AS g
        -- get Users who are members of each group
        JOIN [dbo].[Group User Membership] AS gu
           ON gu.[Group ID] = g.[ID]
        -- get each user's HR data
        JOIN [dbo].[User] AS u
            ON u.[ID] = gu.[User ID]
        -- get each user's registered identifier data
        JOIN [dbo].[User Identifier Association] AS uia
            ON uia.[User ID] = u.[ID]
        JOIN [dbo].[Identifier Scheme] AS idsch
            ON idsch.ID = uia.[Identifier Scheme ID]
WHERE   -- restrict to the group(s) of interest
        g.[name] = 'Feinberg School of Medicine' AND idsch.[Name] = 'scopus-author-id'
ORDER BY
        "Group Name",
        "Last Name",
        "First Name"


-- How do I find our if a paper with a specific DOI is in the database?
use [Elements-reporting2]
SELECT *
FROM [dbo].[Publication Record] as pr
WHERE pr.[doi] = 'doi_name_1' OR pr.[doi] = 'doi_name_2' OR ...


-- How do I return a list of all users in a group that have a [Scopus, ORCID, WOS] author ID?
use [Elements-reporting2]

SELECT  DISTINCT g.[Name] AS "Group Name",
        u.[Last Name],
        u.[First Name],
        u.[Department],
        u.[Username] AS "NetID",
        u.[Proprietary ID] AS "Employee_ID",
        idsch.[Name] AS "Author_ID_Scheme",
        uia.[Identifier Value] AS "Author_ID"

FROM    [dbo].[Group] AS g
        -- get Users who are members of each group
        JOIN [dbo].[Group User Membership] AS gu
            ON gu.[Group ID] = g.[ID]
        JOIN [dbo].[Publication User Relationship] AS pur
            ON pur.[User ID] = gu.[User ID]
        -- get each user's HR data
        JOIN [dbo].[User] AS u
            ON u.[ID] = pur.[User ID]
        -- get each user's registered identifier data
        JOIN [dbo].[User Identifier Association] AS uia
            ON uia.[User ID] = u.[ID]
        JOIN [dbo].[Identifier Scheme] AS idsch
            ON idsch.ID = uia.[Identifier Scheme ID]
WHERE   -- restrict to the group(s) of interest
        g.[name] = 'group_name' AND idsch.[Name] = 'scopus-author-id'
ORDER BY
        "Group Name",
        "Last Name",
        "First Name",
        "Department",
        "NetID",
        "Employee_ID",
        "Author_ID_Scheme",
        "Author_ID"
;


-- How do I get all publications within a date range for all members of a group?
use [Elements-reporting2]

SELECT g.name, pr.[Publication ID], doi, [Data Source], [Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE [publication-date] > YYYYMMDD AND [publication-date] <= YYYYMMDD AND g.name = 'group_name'
ORDER BY pr.[Publication ID]


-- A similar query with additional author and publication information
-- NOTE: Pubs may have duplicate publication dates, DOIs, and proprietary IDs (Scopus, ORCID, WOS, etc.)
use [Elements-reporting2]

SELECT u.[Last Name], u.[First Name], u.[Username], u.Department, g.name, pr.[Publication ID], pr.[publication-date], pr.[authors], pr.[title], pr.[journal], pr.[publication-status], pr.[types], pr.[external-identifiers], pr.[doi], pr.[Data Source Proprietary ID], pr.[Data Source]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE [publication-date] > YYYYMMDD AND [publication-date] <= YYYYMMDD AND g.name = 'group_name'
ORDER BY u.[Last Name]

-- Querying for authors pubs when authors are in at least one of three groups
-- Also includes Scopus Author ID and Employee_ID
-- NOTE: Pubs may have duplicate publication dates, DOIs, and proprietary IDs (Scopus, ORCID, WOS, etc.)
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


/* Publication Dates: 2014 – 2018
* Non-de-duplicated: We’d like each person to have their own list of publications (i.e. non-de-duplicated publication list), with the person’s name or other identifying information in a column next to their publication.
* IDs: We’d like all possible article IDs in separate columns by database (i.e. PubMed ID, Scopus ID, DOI, WoS, etc.)
*/
use [Elements-reporting2]

SELECT g.[name] as "Group Name", u.[Last Name], u.[First Name], u.[Department], u.Username as "NetID", u.[Proprietary ID] as "Employee_ID", uia.[Identifier Value] as "Scopus AU-ID", pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[User Identifier Association] as uia on uia.[User ID] = u.[ID]
join [dbo].[Identifier Scheme] as idsch on idsch.ID = uia.[Identifier Scheme ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE pr.[publication-date] > 20140101 AND pr.[publication-date] <= 20181231
GROUP BY g.name, u.[Last Name], u.[First Name], u.[Department], u.Username, u.[Proprietary ID], uia.[Identifier Value], pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
HAVING g.name = 'CCCR_2018'
ORDER BY u.[Last Name]


-- Database query, all pubs
use [Elements-reporting2]

SELECT g.[name] as "Group Name", u.[Last Name], u.[First Name], u.[Department], u.Username as "NetID", u.[Proprietary ID] as "Employee_ID", uia.[Identifier Value] as "Scopus AU-ID", pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[User Identifier Association] as uia on uia.[User ID] = u.[ID]
join [dbo].[Identifier Scheme] as idsch on idsch.ID = uia.[Identifier Scheme ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE pr.[publication-date] > 20160101 AND pr.[publication-date] <= 20181231
GROUP BY g.name, u.[Last Name], u.[First Name], u.[Department], u.Username, u.[Proprietary ID], uia.[Identifier Value], pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
HAVING g.name = 'GIM_Ger_2016-2018'
ORDER BY u.[Last Name]


-- Database query, all pubs
use [Elements-reporting2]

SELECT g.[name] as "Group Name", u.[Last Name], u.[First Name], u.[Department], u.Username as "NetID", u.[Proprietary ID] as "Employee_ID", uia.[Identifier Value] as "Scopus AU-ID", pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[User Identifier Association] as uia on uia.[User ID] = u.[ID]
join [dbo].[Identifier Scheme] as idsch on idsch.ID = uia.[Identifier Scheme ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE pr.[publication-date] > 20170901 AND pr.[publication-date] <= 20180831
GROUP BY g.name, u.[Last Name], u.[First Name], u.[Department], u.Username, u.[Proprietary ID], uia.[Identifier Value], pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
HAVING g.name = 'DPM_20180905_NetID'
ORDER BY u.[Last Name]


-- Database query, all pubs, no date limit
use [Elements-reporting2]

SELECT u.[First Name], u.[Department], u.Username as "NetID", u.[Proprietary ID] as "Employee_ID", uia.[Identifier Value] as "Scopus AU-ID", pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[User Identifier Association] as uia on uia.[User ID] = u.[ID]
join [dbo].[Identifier Scheme] as idsch on idsch.ID = uia.[Identifier Scheme ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE u.[Department] like 'Pediatrics%'
GROUP BY u.[Last Name], u.[First Name], u.[Department], u.Username, u.[Proprietary ID], uia.[Identifier Value], pr.[Publication ID], pr.[publication-date], doi, pr.[Data Source], pr.[Data Source Proprietary ID]
ORDER BY u.[Last Name]


-- Returns all publications within a date range for researchers in group 'group_name'. Further comments on the 'Reporting Date 1' field needed.

use [Elements-reporting2]

SELECT  g.[Name] AS "Group Name",
        u.[Last Name],
        u.[First Name],
        u.[Department],
        u.[Username] AS "NetID",
        u.[Proprietary ID] AS "Employee_ID",
        idsch.[Name] AS "Author_ID_Scheme",
        uia.[Identifier Value] AS "Author_ID",
        pr.[Publication ID],
        pr.[publication-date],
        pr.[doi],
        pr.[Data Source],
        pr.[Data Source Proprietary ID],
        pr.[title],
        pr.[abstract],
        pr.[authors],
        pr.[issue],
        pr.[journal],
        pr.[volume],
        pr.[types]
FROM    -- start with Groups
        [dbo].[Group] AS g
        -- get Users who are members of each group
        JOIN [dbo].[Group User Membership] AS gu
           ON gu.[Group ID] = g.[ID]
        -- get the publications linked to each user
        JOIN [dbo].[Publication User Relationship] AS pur
            ON pur.[User ID] = gu.[User ID]
        JOIN [dbo].[Publication] p
            ON p.[ID] = pur.[Publication ID]
        -- get all records for each publication
        JOIN [dbo].[Publication Record] AS pr
            ON pr.[Publication ID] = p.[ID]
        -- get each user's HR data
        JOIN [dbo].[User] AS u
            ON u.[ID] = pur.[User ID]
        -- get each user's registered identifier data
        JOIN [dbo].[User Identifier Association] AS uia
            ON uia.[User ID] = u.[ID]
        JOIN [dbo].[Identifier Scheme] AS idsch
            ON idsch.ID = uia.[Identifier Scheme ID]
WHERE   -- restrict to the group(s) of interest
        g.[name] = 'group_name'
        -- restrict to the time range of interest, using the Publication object's Reporting Date 1. Include publications with no Reporting Date 1
        AND ( (p.[Reporting Date 1] > YYYYMMDD AND p.[Reporting Date 1] <= YYYYMMDD ) OR (pr.[publication-date] > YYYYMMDD AND pr.[publication-date] <= YYYYMMDD) OR p.[Reporting Date 1] IS NULL )
ORDER BY
        "Group Name",
        "Last Name",
        "First Name",
        "Department",
        "NetID",
        "Employee_ID",
        "Author_ID_Scheme",
        "Author_ID",
        "Publication ID",
        "publication-date",
        "doi",
        "Data Source",
        "Data Source Proprietary ID",
        "title",
        "abstract",
        "authors",
        "issue",
        "journal",
        "volume",
        "types"
;
