TRUNCATE TABLE [CovidDW].[Tmp].[StageTable]

---INSERT Confirmed, Deaths, Recovered
INSERT INTO [CovidDW].[Tmp].[StageTable]([Country], [Date], [Confirmed], [Deaths], [Recovered])
	SELECT [Tmp].[ConfirmedTotal].[Country], [Tmp].[ConfirmedTotal].[Date], [Tmp].[ConfirmedTotal].[Confirmed], [Tmp].[DeathsTotal].[Deaths], [Tmp].[RecoveredTotal].[Recovered]
	FROM [CovidDW].[Tmp].[ConfirmedTotal]
	INNER JOIN [CovidDW].[Tmp].[DeathsTotal] ON [Tmp].[ConfirmedTotal].[Country] = [Tmp].[DeathsTotal].[Country] AND [Tmp].[ConfirmedTotal].[Date] = [Tmp].[DeathsTotal].[Date]
	INNER JOIN [CovidDW].[Tmp].[RecoveredTotal] ON [Tmp].[ConfirmedTotal].[Country] = [Tmp].[RecoveredTotal].[Country] AND [Tmp].[ConfirmedTotal].[Date] = [Tmp].[RecoveredTotal].[Date]
	ORDER BY [Country], [Date] ASC;
DROP TABLE [CovidDW].[Tmp].[ConfirmedTotal]
DROP TABLE [CovidDW].[Tmp].[DeathsTotal]
DROP TABLE [CovidDW].[Tmp].[RecoveredTotal]

--- UPDATE StageTable with Geography
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[GeoKey] = [Covid].[DimGeography].[GeoKey],
[Tmp].[StageTable].[Continent] = [Covid].[DimGeography].[Continent],
[Tmp].[StageTable].[Population] = [Covid].[DimGeography].[Population],
[Tmp].[StageTable].[GDP] = [Covid].[DimGeography].[GDP]
FROM [CovidDW].[Tmp].[StageTable]
INNER JOIN [Covid].[DimGeography] ON [Tmp].[StageTable].[Country] = [Covid].[DimGeography].[Country]

---UPDATE StageTable with Date
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[DateKey] = [Covid].[DimDate].[DateKey],
[Tmp].[StageTable].[Year] = [Covid].[DimDate].[Year],
[Tmp].[StageTable].[Month] = [Covid].[DimDate].[Month],
[Tmp].[StageTable].[MonthName] = [Covid].[DimDate].[MonthName],
[Tmp].[StageTable].[Day] = [Covid].[DimDate].[Day]
FROM [CovidDW].[Tmp].[StageTable]
INNER JOIN [Covid].[DimDate] ON [Tmp].[StageTable].[Date] = [Covid].[DimDate].[Date]

---UPDATE zeros in DaysFromFirstDetection
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[DaysFromFirstDetection] = 0
FROM (
	SELECT [Date], [Confirmed], [Country],
		ROW_NUMBER() OVER (PARTITION BY [Country] ORDER BY [Country]) as [DaysFromFirstDetection]
	FROM [CovidDW].[Tmp].[StageTable]
	WHERE [Confirmed] = 0) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE non zeros in DaysFromFirstDetection
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[DaysFromFirstDetection] = [OtherTable].[DaysFromFirstDetection]
FROM (
	SELECT [Date], [Confirmed], [Country],
		ROW_NUMBER() OVER (PARTITION BY [Country] ORDER BY [Country]) as [DaysFromFirstDetection]
	FROM [CovidDW].[Tmp].[StageTable]
	WHERE [Confirmed] > 0) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE StageTable with DayNumberKey
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[DetectionKey] = [Covid].[DimFirstDetection].[DetectionKey]
FROM [CovidDW].[Tmp].[StageTable]
INNER JOIN [Covid].[DimFirstDetection] ON [Tmp].[StageTable].[DaysFromFirstDetection] = [Covid].[DimFirstDetection].[DaysFromFirstDetection]

---UPDATE zeros in NewCases
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[NewCases] = 0
FROM (
	SELECT [Date], [Country]
	FROM [CovidDW].[Tmp].[StageTable]
	WHERE [Confirmed] = 0) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE non zeros in NewCases
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[NewCases] = ([Tmp].[StageTable].[Confirmed] - [OtherTable].[Lag])
FROM (
	SELECT [Date], [Confirmed], [Country],
		LAG([Confirmed], 1, 0) OVER(PARTITION BY [Country] ORDER BY [Country]) AS [Lag]
	FROM [CovidDW].[Tmp].[StageTable]) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE negative values of NewCases
UPDATE [CovidDW].[Tmp].[StageTable]
SET [NewCases] = 0
WHERE [NewCases] <= 0

---UPDATE zeros in NewDeaths
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[NewDeaths] = 0
FROM (
	SELECT [Date], [Country]
	FROM [CovidDW].[Tmp].[StageTable]
	WHERE [Deaths] = 0) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE non zeros in NewDeaths
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[NewDeaths] = ([Tmp].[StageTable].[Deaths] - [OtherTable].[Lag])
FROM (
	SELECT [Date], [Deaths], [Country],
		LAG([Deaths], 1, 0) OVER(PARTITION BY [Country] ORDER BY [Country]) AS [Lag]
	FROM [CovidDW].[Tmp].[StageTable]) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE negative values of NewDeaths
UPDATE [CovidDW].[Tmp].[StageTable]
SET [NewDeaths] = 0
WHERE [NewDeaths] <= 0

---UPDATE zeros in NewRecovered
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[NewRecovered] = 0
FROM (
	SELECT [Date], [Country]
	FROM [CovidDW].[Tmp].[StageTable]
	WHERE [Recovered] = 0) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE non zeros in NewRecovered
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[NewRecovered] = ([Tmp].[StageTable].[Recovered] - [OtherTable].[Lag])
FROM (
	SELECT [Date], [Recovered], [Country],
		LAG([Recovered], 1, 0) OVER(PARTITION BY [Country] ORDER BY [Country]) AS [Lag]
	FROM [CovidDW].[Tmp].[StageTable]) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

---UPDATE negative values of NewDeaths
UPDATE [CovidDW].[Tmp].[StageTable]
SET [NewRecovered] = 0
WHERE [NewRecovered] <= 0

---UPDATE CasesDynamic
UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[CasesDynamic] = [Tmp].[StageTable].[NewCases] / NULLIF([OtherTable].[Lag], 0)
FROM (
	SELECT [Date], [NewCases], [Country],
		LAG([NewCases], 1, 0) OVER(PARTITION BY [Country] ORDER BY [Country]) AS [Lag]
	FROM [CovidDW].[Tmp].[StageTable]) AS OtherTable
WHERE
	[OtherTable].[Date] = [Tmp].[StageTable].[Date] and [OtherTable].[Country] = [Tmp].[StageTable].[Country]

UPDATE [CovidDW].[Tmp].[StageTable]
SET [Tmp].[StageTable].[CasesDynamic] = 0
WHERE [Tmp].[StageTable].[CasesDynamic] IS NULL
