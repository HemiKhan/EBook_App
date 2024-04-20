USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_AirPort_List]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_AirPort_List](
	[TimeStamp] [timestamp] NOT NULL,
	[AL_ID] [int] NOT NULL,
	[AIRPORT_CODE] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Number] [nvarchar](20) NOT NULL,
	[Address] [nvarchar](250) NOT NULL,
	[Address2] [nvarchar](250) NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [nvarchar](10) NOT NULL,
	[ZipCode] [nvarchar](10) NOT NULL,
	[County] [nvarchar](50) NOT NULL,
	[CountryRegionCode] [nvarchar](10) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_AirPort_List] PRIMARY KEY CLUSTERED 
(
	[AL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_AirPort_List] ADD  CONSTRAINT [DF_T_AirPort_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_AirPort_List] ADD  CONSTRAINT [DF_T_AirPort_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
