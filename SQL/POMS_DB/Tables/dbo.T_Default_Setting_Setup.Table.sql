USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Default_Setting_Setup]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Default_Setting_Setup](
	[TimeStamp] [timestamp] NOT NULL,
	[DSS] [int] IDENTITY(1,1) NOT NULL,
	[CONFIG_TYPE] [nvarchar](50) NOT NULL,
	[Description_] [nvarchar](1000) NOT NULL,
	[REFNO1] [nvarchar](50) NULL,
	[REFNO2] [nvarchar](50) NULL,
	[REFNO3] [nvarchar](50) NULL,
	[REFID1] [int] NULL,
	[REFID2] [int] NULL,
	[REFID3] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Default_Setting_Setup] PRIMARY KEY CLUSTERED 
(
	[DSS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Default_Setting_Setup] ADD  CONSTRAINT [DF_T_Default_Setting_Setup_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Default_Setting_Setup] ADD  CONSTRAINT [DF_T_Default_Setting_Setup_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Default_Setting_Setup]  WITH CHECK ADD  CONSTRAINT [FK_T_Default_Setting_Setup_T_Setting_Config_Type] FOREIGN KEY([CONFIG_TYPE])
REFERENCES [dbo].[T_Default_Setup_Config_Type] ([CONFIG_TYPE])
GO
ALTER TABLE [dbo].[T_Default_Setting_Setup] CHECK CONSTRAINT [FK_T_Default_Setting_Setup_T_Setting_Config_Type]
GO
