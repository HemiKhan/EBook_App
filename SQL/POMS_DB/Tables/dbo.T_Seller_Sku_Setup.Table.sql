USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Seller_Sku_Setup]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Seller_Sku_Setup](
	[TimeStamp] [timestamp] NOT NULL,
	[SSS_ID] [int] IDENTITY(1,1) NOT NULL,
	[SELLER_KEY] [nvarchar](36) NOT NULL,
	[Type_MTV_CODE] [nvarchar](20) NULL,
	[MasterSKU_No] [nvarchar](150) NOT NULL,
	[MasterSKUDescription] [nvarchar](500) NULL,
	[SKU_No] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[IsMasterSKU] [bit] NOT NULL,
	[Weight] [decimal](18, 6) NOT NULL,
	[WeightUnit_MTV_CODE] [nvarchar](20) NOT NULL,
	[DimLength] [decimal](18, 6) NOT NULL,
	[DimWidth] [decimal](18, 6) NOT NULL,
	[DimHeight] [decimal](18, 6) NOT NULL,
	[DimUnit_MTV_CODE] [nvarchar](20) NOT NULL,
	[CalculatedCuFt] [decimal](18, 6) NOT NULL,
	[UserCuFt] [decimal](18, 6) NULL,
	[Value] [decimal](18, 6) NULL,
	[AssemblyTime] [int] NULL,
	[Sort_] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Seller_Sku_Setup] PRIMARY KEY CLUSTERED 
(
	[SSS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Seller_Sku_Setup] ADD  CONSTRAINT [DF_T_Seller_Sku_Setup_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Seller_Sku_Setup] ADD  CONSTRAINT [DF_T_Seller_Sku_Setup_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Seller_Sku_Setup]  WITH CHECK ADD  CONSTRAINT [const_T_Seller_Sku_Setup_MasterSkuCheck] CHECK  ((upper(rtrim(ltrim([MasterSKU_No])))=upper(rtrim(ltrim([SKU_No]))) AND [IsMasterSKU]=(0) AND [MasterSKUDescription]='' OR upper(rtrim(ltrim([MasterSKU_No])))<>upper(rtrim(ltrim([SKU_No]))) AND [IsMasterSKU]=(1) AND [MasterSKUDescription]<>''))
GO
ALTER TABLE [dbo].[T_Seller_Sku_Setup] CHECK CONSTRAINT [const_T_Seller_Sku_Setup_MasterSkuCheck]
GO
