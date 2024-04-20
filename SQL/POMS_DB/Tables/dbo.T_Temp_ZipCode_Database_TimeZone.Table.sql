USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Temp_ZipCode_Database_TimeZone]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Temp_ZipCode_Database_TimeZone](
	[Name] [nvarchar](50) NOT NULL,
	[UTC] [nvarchar](20) NOT NULL,
	[IsDayLightSavingExists] [bit] NOT NULL,
	[Time Zone] [nvarchar](50) NULL,
	[TimeZoneAbbr] [nvarchar](20) NULL
) ON [PRIMARY]
GO
