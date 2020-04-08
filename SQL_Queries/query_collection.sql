-- How can I count the number of deleted orphan publications per day?
-- NOTE: This should be run on the application server
use [Elements]

SELECT CAST(ModifiedWhen AS DATE) AS 'Date', Count(1) AS 'Orphans deleted'
FROM [dbo].[OBJECT_tblObject]
WHERE Deleted=1
AND DeleteIfOrphaned=1
AND ModifiedWhen > '2019-01-01'
GROUP BY CAST(ModifiedWhen AS DATE)
ORDER BY CAST(ModifiedWhen AS DATE) ASC


-- How do I get a list of all publications for each user in a group along with all of their Author_IDs?

SELECT g.[name] as "Group Name", u.[Last Name], u.[First Name], u.Username as "NetID", u.[Email], u.[Department], u.[Proprietary ID] as "Employee_ID", uia.[Identifier Value] as "Author ID", idsch.[Name] as "Author ID Scheme", pr.[Publication ID], pr.[authors], pr.[title], pr.[journal], pr.[publication-date], pr.[volume], pr.[issue], pr.[pagination Begin], pr.[pagination End], pr.[publication-status], pr.[types], pr.[external-identifiers], pr.[doi], pr.[Data Source Proprietary ID], pr.[Data Source]
FROM [dbo].[Publication Record] as pr
join [dbo].[Publication User Relationship] as pu on pr.[Publication ID] = pu.[Publication ID]
join [dbo].[Group User Membership] as gu on gu.[User ID] = pu.[User ID]
join [dbo].[User] as u on u.[ID] = pu.[User ID]
join [dbo].[] AS ui on ui.[User ID] = u.[ID]
join [dbo].[Identifier Scheme] as idsch on idsch.ID = uia.[Identifier Scheme ID]
join [dbo].[Group] as g on g.[ID] = gu.[Group ID]
WHERE pr.[publication-date] > YYYYMMDD AND pr.[publication-date] <= YYYYMMDD AND g.name = 'group_name'
ORDER BY u.[Last Name]


-- How do I generate a list of researchers with aggregate counts of pending publications by type (conference and journal article)
-- Modified by Ben Heartland at Symplectic

SELECT  u.[Computed Name Abbreviated]
         ,LEFT(u.[Department],  CHARINDEX(';', u.[Department])) "True Department"
         ,RIGHT(u.[Department], LEN(u.[Department]) - CHARINDEX(';', u.[Department])) "True School"
         ,p.[Type],
         COUNT(p.ID) AS "Pending Publication Count"
FROM    [User] u
         -- Left joins mean we report on every user, even if they have no pending publications.
         -- See https://docs.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql#join-type
         LEFT JOIN [Pending Publication] pp ON pp.[User ID] = u.ID
         LEFT JOIN [Publication] p ON p.ID = pp.[Publication ID]
GROUP BY [Computed Name Abbreviated]
         ,u.[Department]
         ,p.[Type]
ORDER BY [Computed Name Abbreviated]
         ,[True Department]
         ,[True School]
         ,p.[Type]
;

-- How do I find users who have secondary appointments in Feinberg?

SELECT [ID]
,[User Record ID]
,[Username]
,[Position]
,[Title]
,[First Name]
,[Last Name]
,[Initials]
,[Computed Name Alphabetical]
,[Email]
,[Primary Group Descriptor]
,[Is Academic]
,[Is Current Staff]
,[Is Local]
,[Is Login Allowed]
,[Department]
,[Dept0]
,[Dept1]
,[Dept2]
,[Dept3]
,[Dept4]
,[Dept5]
,[Dept6]
,[Dept7]
,[Dept8]
,[Dept9]
,[DeptClass0]
,[DeptClass1]
,[DeptClass2]
,[DeptClass3]
,[DeptClass4]
,[DeptClass5]
,[DeptClass6]
,[DeptClass7]
,[DeptClass8]
,[DeptClass9]
,[DeptGroup0]
,[DeptGroup1]
,[DeptGroup2]
,[DeptGroup3]
,[DeptGroup4]
,[DeptGroup5]
,[DeptGroup6]
,[DeptGroup7]
,[DeptGroup8]
,[DeptGroup9]
  FROM [Elements-reporting2].[dbo].[User]
  WHERE [Primary Group Descriptor] <> 'Feinberg School of Medicine' AND
		([Dept1] like '%MED-%' OR [Dept2] like '%MED-%' OR [Dept3] like '%MED-%' OR [Dept4] like '%MED-%' OR [Dept5] like '%MED-%' OR [Dept6] like '%MED-%' OR [Dept7] like '%MED-%' OR [Dept8] like '%MED-%' OR [Dept9] like '%MED-%' OR
    [Dept1] like '%Feinberg%' OR [Dept2] like '%Feinberg%' OR [Dept3] like '%Feinberg%' OR [Dept4] like '%Feinberg%' OR [Dept5] like '%Feinberg%' OR [Dept6] like '%Feinberg%' OR [Dept7] like '%Feinberg%' OR [Dept8] like '%Feinberg%' OR [Dept9] like '%Feinberg%' OR
		[DeptClass1] like '%Feinberg%' OR [DeptClass2] like '%Feinberg%' OR [DeptClass3] like '%Feinberg%' OR [DeptClass4] like '%Feinberg%' OR [DeptClass5] like '%Feinberg%' OR [DeptClass6] like '%Feinberg%' OR [DeptClass7] like '%Feinberg%' OR [DeptClass8] like '%Feinberg%' OR [DeptClass9] like '%Feinberg%' OR
		[DeptClass1] like '%MED-%' OR [DeptClass2] like '%MED-%' OR [DeptClass3] like '%MED-%' OR [DeptClass4] like '%MED-%' OR [DeptClass5] like '%MED-%' OR [DeptClass6] like '%MED-%' OR [DeptClass7] like '%MED-%' OR [DeptClass8] like '%MED-%' OR [DeptClass9] like '%MED-%' OR
		[DeptGroup1] like '%Feinberg%' OR [DeptGroup2] like '%Feinberg%' OR [DeptGroup3] like '%Feinberg%' OR [DeptGroup4] like '%Feinberg%' OR [DeptGroup5] like '%Feinberg%' OR [DeptGroup6] like '%Feinberg%' OR [DeptGroup7] like '%Feinberg%' OR [DeptGroup8] like '%Feinberg%' OR [DeptGroup9] like '%Feinberg%' OR
		[DeptGroup1] like '%MED-%' OR [DeptGroup2] like '%MED-%' OR [DeptGroup3] like '%MED-%' OR [DeptGroup4] like '%MED-%' OR [DeptGroup5] like '%MED-%' OR [DeptGroup6] like '%MED-%' OR [DeptGroup7] like '%MED-%' OR [DeptGroup8] like '%MED-%' OR [DeptGroup9] like '%MED-%')
  ORDER BY [Last Name]

-- How do I count the number of pending publications for a user?
-- Modified from Karen's version

SELECT [Computed Name Abbreviated], True_Department, True_School, count([Publication ID]) as Pending_Publications_Alt
FROM
  (
    SELECT DISTINCT
      a.[Publication ID],
      a.[User ID] as User_ID,
      b.[Publication ID] as [Alt Publication ID],
      e.[User Record ID],
      e.[Computed Name Abbreviated],
      e.[Department],
      left(e.[Department],  CHARINDEX(';', e.[Department])) as True_Department,
      right(e.[Department], len(e.[Department]) - charindex(';', e.[Department]))  AS True_School,
      e.[Email],
      e.[Is Academic],
      f.[ID] as F_ID,
      f.[User ID]  as F_User_ID
    FROM
      [User Record] f
      INNER JOIN [User] e
      	ON e.[User Record ID] = f.[ID]
      INNER JOIN [Pending Publication] a
      	ON f.[User ID] = a.[User ID]
      INNER JOIN [Publication Record] b
      	ON a.[Publication ID] = b.[Publication ID]
    WHERE f.[ID] = 'ID from User Record table'
)
z

GROUP BY [Computed Name Abbreviated], True_Department, True_School
ORDER BY [Computed Name Abbreviated], True_Department, True_School


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
        JOIN [dbo].[User Identifier] AS ui
            on ui.[User ID] = u.[ID]
        JOIN [dbo].[Identifier Scheme] AS idsch
            ON idsch.ID = uia.[Identifier Scheme ID]
WHERE   -- restrict to the group(s) of interest
        -- remove 'AND' clause to return all author identifiers (Scopus, ORCID, WOS)
        g.[name] = 'Feinberg School of Medicine' AND idsch.[Name] = 'scopus-author-id'
ORDER BY
        "Group Name",
        "Last Name",
        "First Name"


-- How do I return a list of all users in a group that have a [Scopus, ORCID, WOS] author ID? (Problematic, DON'T USE)
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
        -- joining these ids leaves out a small % of authors. Need to look into this.
        JOIN [dbo].[Publication User Relationship] AS pur
            ON pur.[User ID] = gu.[User ID]
        -- get each user's HR data
        JOIN [dbo].[User] AS u
            ON u.[ID] = pur.[User ID]
        -- get each user's registered identifier data
        JOIN [dbo].[User Identifier] AS ui
            on ui.[User ID] = u.[ID]
        JOIN [dbo].[Identifier Scheme] AS idsch
            ON idsch.ID = uia.[Identifier Scheme ID]
WHERE   -- restrict to the group(s) of interest
        g.[name] = 'group_name'
ORDER BY
        "Group Name",
        "Last Name",
        "First Name",
        "Department",
        "NetID",
        "Employee_ID",
        "Author_ID_Scheme",
        "Author_ID"


-- How do I find our if a paper with a specific DOI is in the database?
use [Elements-reporting2]

SELECT *
FROM [dbo].[Publication Record] as pr
WHERE pr.[doi] = 'doi_name_1' OR pr.[doi] = 'doi_name_2' OR ...


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
join [dbo].[User Identifier] AS ui on ui.[User ID] = u.[ID]
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
join [dbo].[User Identifier] AS ui on ui.[User ID] = u.[ID]
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
join [dbo].[User Identifier] AS ui on ui.[User ID] = u.[ID]
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
join [dbo].[User Identifier] AS ui on ui.[User ID] = u.[ID]
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
join [dbo].[User Identifier] AS ui on ui.[User ID] = u.[ID]
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
        JOIN [dbo].[User Identifier] AS ui
            on ui.[User ID] = u.[ID]
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
