---CONFIRMED
DECLARE
  @fullDW		NVARCHAR(257) = N'[CovidDW].[Tmp].[time_series_covid19_confirmed_global]',
  @table        NVARCHAR(257) = N'Tmp.time_series_covid19_confirmed_global', 
  @key_column   SYSNAME       = N'[Country/Region]',
  @name_pattern SYSNAME       = N'[0-9]%';
-- local variables
DECLARE 
  @sql  NVARCHAR(MAX) = N'',
  @cols NVARCHAR(MAX) = N'';
SELECT @cols += ', ' + QUOTENAME(name)
  FROM sys.columns
  WHERE [object_id] = OBJECT_ID(@table)
  AND name <> @key_column
  AND name LIKE @name_pattern;
SELECT @sql = N'SELECT ' + @key_column + ', Date, Confirmed into Tmp.Confirmed FROM ' + @fullDW + '
  UNPIVOT
  (
	Confirmed
    FOR Date IN (' + STUFF(@cols, 1, 1, '') + ')
  )AS up;';
--PRINT @sql;
EXEC sp_executesql @sql;
EXEC sp_RENAME 'CovidDW.Tmp.Confirmed.Country/Region', 'Country', 'COLUMN'
DROP TABLE [Tmp].[time_series_covid19_confirmed_global]

ALTER TABLE [CovidDW].[Tmp].[Confirmed]
ALTER COLUMN [Confirmed] float
ALTER TABLE [CovidDW].[Tmp].[Confirmed]
ALTER COLUMN [Date] date;

SELECT [Country], [Date], sum([Confirmed]) as Confirmed INTO [Tmp].[ConfirmedTotal]
FROM [CovidDW].[Tmp].[Confirmed]
GROUP BY [Date], [Country];
DROP TABLE [CovidDW].[Tmp].[Confirmed]

---DEATHS
DECLARE
  @fullDW2		NVARCHAR(257) = N'[CovidDW].[Tmp].[time_series_covid19_deaths_global]',
  @table2        NVARCHAR(257) = N'Tmp.time_series_covid19_deaths_global', 
  @key_column2   SYSNAME       = N'[Country/Region]',
  @name_pattern2 SYSNAME       = N'[0-9]%';
-- local variables
DECLARE 
  @sql2  NVARCHAR(MAX) = N'',
  @cols2 NVARCHAR(MAX) = N'';
SELECT @cols2 += ', ' + QUOTENAME(name)
  FROM sys.columns
  WHERE [object_id] = OBJECT_ID(@table2)
  AND name <> @key_column2
  AND name LIKE @name_pattern2;
SELECT @sql2 = N'SELECT ' + @key_column2 + ', Date, Deaths into Tmp.Deaths FROM ' + @fullDW2 + '
  UNPIVOT
  (
	Deaths
    FOR Date IN (' + STUFF(@cols2, 1, 1, '') + ')
  )AS up;';
--PRINT @sql2;
EXEC sp_executesql @sql2;
EXEC sp_RENAME 'CovidDW.Tmp.Deaths.Country/Region', 'Country', 'COLUMN'
DROP TABLE [Tmp].[time_series_covid19_deaths_global]

ALTER TABLE [CovidDW].[Tmp].[Deaths]
ALTER COLUMN [Deaths] float
ALTER TABLE [CovidDW].[Tmp].[Deaths]
ALTER COLUMN [Date] date;

SELECT [Country], [Date], sum([Deaths]) as Deaths INTO [Tmp].[DeathsTotal]
FROM [CovidDW].[Tmp].[Deaths]
GROUP BY [Date], [Country];
DROP TABLE [CovidDW].[Tmp].[Deaths]

---RECOVERED
DECLARE
  @fullDW3		NVARCHAR(257) = N'[CovidDW].[Tmp].[time_series_covid19_recovered_global]',
  @table3        NVARCHAR(257) = N'Tmp.time_series_covid19_recovered_global', 
  @key_column3   SYSNAME       = N'[Country/Region]',
  @name_pattern3 SYSNAME       = N'[0-9]%';
-- local variables
DECLARE 
  @sql3  NVARCHAR(MAX) = N'',
  @cols3 NVARCHAR(MAX) = N'';
SELECT @cols3 += ', ' + QUOTENAME(name)
  FROM sys.columns
  WHERE [object_id] = OBJECT_ID(@table3)
  AND name <> @key_column3
  AND name LIKE @name_pattern3;
SELECT @sql3 = N'SELECT ' + @key_column3 + ', Date, Recovered into Tmp.Recovered FROM ' + @fullDW3 + '
  UNPIVOT
  (
	Recovered
    FOR Date IN (' + STUFF(@cols3, 1, 1, '') + ')
  )AS up;';
--PRINT @sql3;
EXEC sp_executesql @sql3;
EXEC sp_RENAME 'CovidDW.Tmp.Recovered.Country/Region', 'Country', 'COLUMN'
DROP TABLE [Tmp].[time_series_covid19_recovered_global]

ALTER TABLE [CovidDW].[Tmp].[Recovered]
ALTER COLUMN [Recovered] float
ALTER TABLE [CovidDW].[Tmp].[Recovered]
ALTER COLUMN [Date] date;

SELECT [Country], [Date], sum([Recovered]) as Recovered INTO [Tmp].[RecoveredTotal]
FROM [CovidDW].[Tmp].[Recovered]
GROUP BY [Date], [Country];
DROP TABLE [CovidDW].[Tmp].[Recovered]
