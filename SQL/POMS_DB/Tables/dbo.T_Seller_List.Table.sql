USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Seller_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Seller_List](
	[TimeStamp] [timestamp] NOT NULL,
	[SELLER_ID] [int] NOT NULL,
	[SELLER_CODE] [nvarchar](20) NOT NULL,
	[SELLER_KEY] [nvarchar](36) NOT NULL,
	[Company] [nvarchar](250) NOT NULL,
	[ContactPerson] [nvarchar](250) NOT NULL,
	[Address] [nvarchar](250) NOT NULL,
	[Address2] [nvarchar](250) NULL,
	[City] [nvarchar](50) NOT NULL,
	[State] [nvarchar](20) NOT NULL,
	[ZipCode] [nvarchar](10) NOT NULL,
	[County] [nvarchar](50) NOT NULL,
	[CountryRegionCode] [nvarchar](10) NULL,
	[EmailTo] [nvarchar](1000) NOT NULL,
	[EmailCC] [nvarchar](1000) NULL,
	[Mobile] [nvarchar](30) NULL,
	[Mobile2] [nvarchar](30) NULL,
	[Phone] [nvarchar](30) NOT NULL,
	[PhoneExt] [nvarchar](10) NULL,
	[Phone2] [nvarchar](30) NULL,
	[Phone2Ext] [nvarchar](10) NULL,
	[D_ID] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Seller_List] PRIMARY KEY CLUSTERED 
(
	[SELLER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Seller_List] ADD  CONSTRAINT [DF_T_Seller_List_SELLER_KEY]  DEFAULT (upper(newid())) FOR [SELLER_KEY]
GO
ALTER TABLE [dbo].[T_Seller_List] ADD  CONSTRAINT [DF_T_Seller_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
