---Dimension Geography
CREATE TABLE [Covid].[DimGeography]
	(
	[GeoKey] [int] IDENTITY(1,1) NOT NULL,
	[Continent] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Population] [bigint] NULL,
	[GDP] [bigint] NULL
PRIMARY KEY CLUSTERED
(
	[GeoKey] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

---Dimension Time
CREATE TABLE [Covid].[DimDate]
	(
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] [varchar](50) NOT NULL,
	[Year] [int] NOT NULL
PRIMARY KEY CLUSTERED
(
	[DateKey] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

---Dimension First Detection
CREATE TABLE [Covid].[DimFirstDetection]
	(
	[DetectionKey] [int] IDENTITY(1,1) NOT NULL,
	[DaysFromFirstDetection] [int] NOT NULL
PRIMARY KEY CLUSTERED
(
	[DetectionKey] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	
---Dimension Patient
CREATE TABLE [Covid].[DimPatient]
	(
	[PatientKey] [int] IDENTITY(1,1) NOT NULL,
	[Age] [int] NOT NULL,
	[Gender] [varchar](50) NOT NULL
PRIMARY KEY CLUSTERED
(
	[PatientKey] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

---Stage Table to count measures
CREATE TABLE [Tmp].[StageTable]
	(
	[StageTableKey] [int] IDENTITY(1,1) NOT NULL,
	[GeoKey] [int] NULL,
	[Continent] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Population] [bigint] NULL,
	[GDP] [bigint] NULL,
	[DateKey] [int] NULL,
	[Date] [date] NOT NULL,
	[Day] [tinyint] NULL,
	[Month] [tinyint] NULL,
	[MonthName] [varchar](50) NULL,
	[Year] [int] NULL,
	[DetectionKey] [int] NULL,
	[DaysFromFirstDetection] [int] NULL,
	[Confirmed] [float] NULL,
	[Deaths] [float] NULL,
	[NewDeaths] [float] NULL,
	[Recovered] [float] NULL,
	[NewRecovered] [float] NULL,
	[NewCases] [float] NULL,
	[ActiveCases] AS ([Confirmed] - [Deaths] - [Recovered]) PERSISTED,
	[CasesDynamic] [float] NULL

PRIMARY KEY CLUSTERED
(
	[StageTableKey] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]


---Final Fact Table
CREATE TABLE [CovidDW].[Covid].[CovidFactTable]
	(
	[FactTableKey] [int] NOT NULL,
	[GeoKey] [int] NOT NULL,
	[DateKey] [int] NOT NULL,
	[DetectionKey] [int] NOT NULL,
	[Confirmed] [float] NOT NULL,
	[Deaths] [float] NOT NULL,
	[Recovered] [float] NOT NULL,
	[NewCases] [float] NOT NULL,
	[ActiveCases] [float] NOT NULL,
	[CasesDynamic] [float] NOT NULL,

PRIMARY KEY ([FactTableKey]),

CONSTRAINT [FK_GeoKey] FOREIGN KEY ([GeoKey])
REFERENCES [CovidDW].[Covid].[DimGeography]([GeoKey]),
CONSTRAINT [FK_DateKey] FOREIGN KEY ([DateKey])
REFERENCES [CovidDW].[Covid].[DimDate]([DateKey]),
CONSTRAINT [FK_DetectionKey] FOREIGN KEY ([DetectionKey])
REFERENCES [CovidDW].[Covid].[DimFirstDetection]([DetectionKey])
);
