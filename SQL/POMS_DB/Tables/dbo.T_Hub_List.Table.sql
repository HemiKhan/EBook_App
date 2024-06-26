USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Hub_List]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Hub_List](
	[TimeStamp] [timestamp] NOT NULL,
	[HL_ID] [int] IDENTITY(1,1) NOT NULL,
	[HUB_CODE] [nvarchar](20) NOT NULL,
	[HubName] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](250) NOT NULL,
	[Address2] [nvarchar](250) NOT NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [nvarchar](5) NOT NULL,
	[ZipCode] [nvarchar](10) NOT NULL,
	[County] [nvarchar](50) NOT NULL,
	[CountryRegionCode] [nvarchar](10) NOT NULL,
	[Latitude] [nvarchar](30) NOT NULL,
	[Longitude] [nvarchar](30) NOT NULL,
	[PlaceID] [nvarchar](500) NOT NULL,
	[AIRPORT_CODE] [nvarchar](10) NULL,
	[IsActive] [bit] NOT NULL,
	[IsActiveOnMap] [bit] NOT NULL,
	[TIMEZONE_ID] [int] NOT NULL,
	[Region_MTV_CODE] [nvarchar](20) NOT NULL,
	[SqFeet] [int] NOT NULL,
	[LocationType_MTV_CODE] [nvarchar](20) NOT NULL,
	[HUB_ZONE] [nvarchar](20) NOT NULL,
	[NAV_DIMENSION_CODE] [nvarchar](20) NULL,
	[LHBuffer] [int] NOT NULL,
	[FMBuffer] [int] NOT NULL,
	[ManagerTitle_MTV_CODE] [nvarchar](20) NULL,
	[ManagerName] [nvarchar](150) NULL,
	[Email] [nvarchar](250) NULL,
	[Mobile] [nvarchar](30) NULL,
	[Phone] [nvarchar](20) NULL,
	[PhoneExt] [nvarchar](10) NULL,
	[ContactPerson] [nvarchar](150) NULL,
	[ADDRESS_CODE] [nvarchar](20) NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Hub_List] PRIMARY KEY CLUSTERED 
(
	[HL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Hub_List] ADD  CONSTRAINT [DF_T_Hub_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Hub_List] ADD  CONSTRAINT [DF_T_Hub_List_IsActiveOnMap]  DEFAULT ((1)) FOR [IsActiveOnMap]
GO
ALTER TABLE [dbo].[T_Hub_List] ADD  CONSTRAINT [DF_T_Hub_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
