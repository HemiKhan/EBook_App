USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Zip_Code_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Zip_Code_List](
	[TimeStamp] [timestamp] NOT NULL,
	[ZIP_CODE] [nvarchar](10) NOT NULL,
	[StateName] [nvarchar](50) NOT NULL,
	[State] [nvarchar](10) NOT NULL,
	[Latitude] [nvarchar](30) NOT NULL,
	[Longitude] [nvarchar](30) NOT NULL,
	[AreaType_MTV_ID] [int] NOT NULL,
	[TIMEZONE_ID] [int] NOT NULL,
	[Region_MTV_CODE] [nvarchar](20) NOT NULL,
	[HUB_CODE] [nvarchar](20) NOT NULL,
	[DrivingMiles] [decimal](10, 4) NOT NULL,
	[MilesRadius] [decimal](10, 4) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Zip_Code_List] PRIMARY KEY CLUSTERED 
(
	[ZIP_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Zip_Code_List] ADD  CONSTRAINT [DF_T_Zip_Code_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Zip_Code_List] ADD  CONSTRAINT [DF_T_Zip_Code_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
