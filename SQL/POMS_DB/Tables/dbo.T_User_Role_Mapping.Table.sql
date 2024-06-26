USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_User_Role_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Role_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[URM_ID] [int] IDENTITY(1,1) NOT NULL,
	[USERNAME] [nvarchar](150) NOT NULL,
	[ROLE_ID] [int] NOT NULL,
	[IsGroupRoleID] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Role_Mapping] PRIMARY KEY CLUSTERED 
(
	[URM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_IsGroupRoleID]  DEFAULT ((0)) FOR [IsGroupRoleID]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
