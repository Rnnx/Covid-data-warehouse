---DimDate Insert
SET NOCOUNT ON
TRUNCATE TABLE [Covid].[DimDate]
DECLARE @CurrentDate DATE = '2020-01-01'
DECLARE @EndDate DATE = '2020-12-31'

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO [Covid].[DimDate] (
      [DateKey],
      [Date],
      [Day],
      [Month],
	  [MonthName],
      [Year]
      )
   SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
      DATE = @CurrentDate,
      Day = DAY(@CurrentDate),
      [Month] = MONTH(@CurrentDate),
	  [MonthName] = DATENAME(mm, @CurrentDate),
      [Year] = YEAR(@CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

---FirstDetection Insert
SET NOCOUNT ON
TRUNCATE TABLE [Covid].[DimFirstDetection]
DECLARE @i int = 0

WHILE @i < 10000
BEGIN
	INSERT INTO [Covid].[DimFirstDetection] (
		[DaysFromFirstDetection]
		)
		SELECT [DaysFromFirstDetection] = @i
	SET @i = @i + 1
END
