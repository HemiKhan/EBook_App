USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Default_Setup_Config_Type]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Default_Setup_Config_Type](
	[TimeStamp] [timestamp] NOT NULL,
	[DSCT_ID] [int] IDENTITY(1,1) NOT NULL,
	[CONFIG_TYPE] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Default_Setup_Config_Type] PRIMARY KEY CLUSTERED 
(
	[DSCT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Default_Setup_Config_Type] ADD  CONSTRAINT [DF_T_Default_Setup_Config_Type_Description]  DEFAULT ('') FOR [Description]
GO
ALTER TABLE [dbo].[T_Default_Setup_Config_Type] ADD  CONSTRAINT [DF_T_Default_Setup_Config_Type_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
