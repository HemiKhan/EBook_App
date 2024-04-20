USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Application_Setting_Setup]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Application_Setting_Setup](
	[TimeStamp] [timestamp] NOT NULL,
	[ASS_ID] [int] IDENTITY(1,1) NOT NULL,
	[CONFIG_TYPE_MTV_CODE] [nvarchar](20) NOT NULL,
	[Description_] [nvarchar](1000) NULL,
	[REFNO1] [nvarchar](250) NULL,
	[REFNO2] [nvarchar](250) NULL,
	[REFNO3] [nvarchar](250) NULL,
	[REFID1] [int] NULL,
	[REFID2] [int] NULL,
	[REFID3] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Application_Setting_Setup] PRIMARY KEY CLUSTERED 
(
	[ASS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Application_Setting_Setup] ADD  CONSTRAINT [DF_T_Application_Setting_Setup_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_Setting_Setup] ADD  CONSTRAINT [DF_T_Application_Setting_Setup_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
