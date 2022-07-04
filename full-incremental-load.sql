---CREATE Stage Fact Table
CREATE TABLE [Tmp].[StageCovidFactTable]
	(
	[FactTableKey] [int] IDENTITY(1,1) NOT NULL,
	[GeoKey] [int] NOT NULL,
	[DateKey] [int] NOT NULL,
	[DetectionKey] [int] NOT NULL,
	[Confirmed] [float] NOT NULL,
	[Deaths] [float] NOT NULL,
	[Recovered] [float] NOT NULL,
	[NewCases] [float] NOT NULL,
	[ActiveCases] [float] NOT NULL,
	[CasesDynamic] [float] NOT NULL

PRIMARY KEY CLUSTERED
(
	[FactTableKey] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

---INESRT Data from Stage Table
INSERT INTO [Tmp].[StageCovidFactTable](
				 [GeoKey]
				,[DateKey]
				,[DetectionKey]
				,[Confirmed]
				,[Deaths]
				,[Recovered]
				,[NewCases]
				,[ActiveCases]
				,[CasesDynamic])
			SELECT [GeoKey]
				  ,[DateKey]
				  ,[DetectionKey]
				  ,[Confirmed]
				  ,[Deaths]
				  ,[Recovered]
				  ,[NewCases]
				  ,[ActiveCases]
				  ,[CasesDynamic]
			FROM [Tmp].[StageTable]

---MERGE Stage Fact Table with Real Fact Table
MERGE INTO [Covid].[CovidFactTable] tgt
USING [Tmp].[StageCovidFactTable] src ON tgt.[FactTableKey] = src.[FactTableKey]
WHEN MATCHED AND EXISTS
(
	SELECT src.[GeoKey], src.[DateKey], src.[DetectionKey], src.[Confirmed], src.[Deaths], src.[Recovered], src.[NewCases], src.[ActiveCases], src.[CasesDynamic]
	except
	SELECT tgt.[GeoKey], tgt.[DateKey], tgt.[DetectionKey], tgt.[Confirmed], tgt.[Deaths], tgt.[Recovered], tgt.[NewCases], tgt.[ActiveCases], tgt.[CasesDynamic]
)
THEN UPDATE
SET tgt.[GeoKey] = src.[GeoKey], 
	tgt.[DateKey] = src.[DateKey], 
	tgt.[DetectionKey] = src.[DetectionKey], 
	tgt.[Confirmed] = src.[Confirmed], 
	tgt.[Deaths] = src.[Deaths], 
	tgt.[Recovered] = src.[Recovered], 
	tgt.[NewCases] = src.[NewCases], 
	tgt.[ActiveCases] = src.[ActiveCases], 
	tgt.[CasesDynamic] = src.[CasesDynamic]
WHEN NOT MATCHED BY TARGET THEN INSERT
(
	 [FactTableKey]
	,[GeoKey]
	,[DateKey]
	,[DetectionKey]
	,[Confirmed]
	,[Deaths]
	,[Recovered]
	,[NewCases]
	,[ActiveCases]
	,[CasesDynamic]
)
VALUES
(
	 src.[FactTableKey]
	,src.[GeoKey]
	,src.[DateKey]
	,src.[DetectionKey]
	,src.[Confirmed]
	,src.[Deaths]
	,src.[Recovered]
	,src.[NewCases]
	,src.[ActiveCases]
	,src.[CasesDynamic]
);

---DROP Stage Fact Table
DROP TABLE [Tmp].[StageCovidFactTable]