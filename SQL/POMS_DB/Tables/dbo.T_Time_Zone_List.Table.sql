USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Time_Zone_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Time_Zone_List](
	[TimeStamp] [timestamp] NOT NULL,
	[TIMEZONE_ID] [int] IDENTITY(1,1) NOT NULL,
	[TimeZoneDisplay] [nvarchar](50) NOT NULL,
	[TimeZoneName] [nvarchar](50) NOT NULL,
	[Offset] [nvarchar](30) NOT NULL,
	[UTCOffset] [nvarchar](30) NOT NULL,
	[TimeZoneFullDispaly] [nvarchar](50) NOT NULL,
	[TimeZoneAbbreviation] [nvarchar](10) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Time_Zone_List] PRIMARY KEY CLUSTERED 
(
	[TIMEZONE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Time_Zone_List] ADD  CONSTRAINT [DF_T_Time_Zone_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Time_Zone_List] ADD  CONSTRAINT [DF_T_Time_Zone_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
