USE [Ebook_DB]

Drop Table [dbo].[T_Application_User_Mapping]
Drop Table [dbo].[T_Application]
Drop Table [dbo].[T_Users]

CREATE TABLE [dbo].[T_Application](
	[TimeStamp] [timestamp] NOT NULL,
	[App_ID] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[App_Name] [nvarchar](50) NOT NULL,
	[AppDetail] [nvarchar](300) NULL,
	[AppType_MTV_CODE] [nvarchar](20) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
GO
ALTER TABLE [dbo].[T_Application] ADD  CONSTRAINT [DF_T_Application_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application] ADD  CONSTRAINT [DF_T_Application_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_Users](
	[TimeStamp] [timestamp] NOT NULL,	
	[User_ID] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[UserName] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](250) NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PasswordHash] [nvarchar](250) NOT NULL,
	[PasswordSalt] [nvarchar](250) NOT NULL,
	[PasswordExpiryDateTime] [datetime] NOT NULL,
	[UserType_MTV_CODE] [nvarchar](20) NULL,
	[Department_MTV_CODE] [nvarchar](20) NULL,
	[Designation_MTV_CODE] [nvarchar](20) NULL,
	[BlockType_MTV_CODE] [nvarchar](20) NULL,
	[IsApproved] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsApproved]  DEFAULT ((1)) FOR [IsApproved]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_PasswordExpiry]  DEFAULT (getutcdate()) FOR [PasswordExpiryDateTime]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO


CREATE TABLE [dbo].[T_Application_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[AUM_ID] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[App_ID] INT NOT NULL FOREIGN KEY ([App_ID]) REFERENCES [T_Application]([App_ID]),
	[User_ID] INT NOT NULL FOREIGN KEY ([User_ID]) REFERENCES [T_Users]([User_ID]),
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
GO
ALTER TABLE [dbo].[T_Application_User_Mapping] ADD  CONSTRAINT [DF_T_Application_User_Map_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_User_Mapping] ADD  CONSTRAINT [DF_T_Application_User_Map_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

Drop Table [dbo].[T_Role_Page_Rights_Mapping]
Drop Table [dbo].[T_User_Role_Mapping]
Drop Table [dbo].[T_Role_Group_Mapping]
Drop Table [dbo].[T_Role_Group]
Drop Table [dbo].[T_Roles]

CREATE TABLE [dbo].[T_Roles](
	[TimeStamp] [timestamp] NOT NULL,
	[R_ID] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](50) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsCustomRole] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Roles] PRIMARY KEY CLUSTERED 
(
	[R_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Roles] ADD  CONSTRAINT [DF_T_Roles_IsCustomRole]  DEFAULT ((0)) FOR [IsCustomRole]
GO
ALTER TABLE [dbo].[T_Roles] ADD  CONSTRAINT [DF_T_Roles_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Roles] ADD  CONSTRAINT [DF_T_Roles_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_Role_Group](
	[TimeStamp] [timestamp] NOT NULL,
	[RG_ID] [int] NOT NULL,
	[RoleGroupName] [nvarchar](50) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Role_Group] PRIMARY KEY CLUSTERED 
(
	[RG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Role_Group] ADD  CONSTRAINT [DF_T_Role_Group_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Role_Group] ADD  CONSTRAINT [DF_T_Role_Group_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_Role_Group_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[RGM_ID] [int] IDENTITY(1,1) NOT NULL,
	[RG_ID] [int] NOT NULL,
	[R_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Role_Group_Mapping] PRIMARY KEY CLUSTERED 
(
	[RGM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] ADD  CONSTRAINT [DF_T_Role_Group_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] ADD  CONSTRAINT [DF_T_Role_Group_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Group_Mapping_T_Role_Group] FOREIGN KEY([RG_ID])
REFERENCES [dbo].[T_Role_Group] ([RG_ID])
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] CHECK CONSTRAINT [FK_T_Role_Group_Mapping_T_Role_Group]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Group_Mapping_T_Roles] FOREIGN KEY([R_ID])
REFERENCES [dbo].[T_Roles] ([R_ID])
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] CHECK CONSTRAINT [FK_T_Role_Group_Mapping_T_Roles]
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


Drop Table [dbo].[T_Application_Page_Mapping]
Drop Table [dbo].[T_Application_Page_Group_Mapping]
Drop Table [dbo].[T_Page_Rights]
Drop Table [dbo].[T_Page]
Drop Table [dbo].[T_Page_Group]

CREATE TABLE [dbo].[T_Page_Group](
	[TimeStamp] [timestamp] NOT NULL,
	[PG_ID] [int] NOT NULL,
	[PageGroupName] [nvarchar](50) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page_Group] PRIMARY KEY CLUSTERED 
(
	[PG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Page_Group] ADD  CONSTRAINT [DF_T_Page_Group_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page_Group] ADD  CONSTRAINT [DF_T_Page_Group_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page_Group] ADD  CONSTRAINT [DF_T_Page_Group_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_Page](
	[TimeStamp] [timestamp] NOT NULL,
	[P_ID] [int] NOT NULL,
	[PG_ID] [int] NOT NULL,
	[PageName] [nvarchar](50) NOT NULL,
	[PageURL] [nvarchar](250) NOT NULL,
	[Application_MTV_ID] [int] NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page] PRIMARY KEY CLUSTERED 
(
	[P_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_Application_MTV_ID]  DEFAULT ((148100)) FOR [Application_MTV_ID]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Page]  WITH CHECK ADD  CONSTRAINT [FK_T_Page_T_Page_Group] FOREIGN KEY([PG_ID])
REFERENCES [dbo].[T_Page_Group] ([PG_ID])
GO
ALTER TABLE [dbo].[T_Page] CHECK CONSTRAINT [FK_T_Page_T_Page_Group]
GO
ALTER TABLE [dbo].[T_Page]  WITH CHECK ADD  CONSTRAINT [const_T_Page_Value_ParentIDCheck] CHECK  ((format([PG_ID],'000')=left(format(CONVERT([int],left([P_ID],len([PG_ID]))),'000'),(3))))
GO
ALTER TABLE [dbo].[T_Page] CHECK CONSTRAINT [const_T_Page_Value_ParentIDCheck]
GO

CREATE TABLE [dbo].[T_Page_Rights](
	[TimeStamp] [timestamp] NOT NULL,
	[PR_ID] [int] NOT NULL,
	[P_ID] [int] NOT NULL,
	[PR_CODE] [nvarchar](50) NOT NULL,
	[PageRightName] [nvarchar](50) NOT NULL,
	[PageRightType_MTV_CODE] [nvarchar](20) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page_Rights] PRIMARY KEY CLUSTERED 
(
	[PR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Page_Rights]  WITH CHECK ADD  CONSTRAINT [FK_T_Page_Rights_T_Page] FOREIGN KEY([P_ID])
REFERENCES [dbo].[T_Page] ([P_ID])
GO
ALTER TABLE [dbo].[T_Page_Rights] CHECK CONSTRAINT [FK_T_Page_Rights_T_Page]
GO
ALTER TABLE [dbo].[T_Page_Rights]  WITH CHECK ADD  CONSTRAINT [const_T_Page_Rights_Value_ParentIDCheck] CHECK  ((substring(CONVERT([nvarchar](100),[PR_ID]),(1),len(CONVERT([nvarchar](100),[P_ID])))=CONVERT([nvarchar](100),[P_ID])))
GO
ALTER TABLE [dbo].[T_Page_Rights] CHECK CONSTRAINT [const_T_Page_Rights_Value_ParentIDCheck]
GO

CREATE TABLE [dbo].[T_Role_Page_Rights_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[RPRM_ID] [int] IDENTITY(1,1) NOT NULL,
	[R_ID] [int] NOT NULL,
	[PR_ID] [int] NOT NULL,
	[IsRightActive] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Role_Page_Rights_Mapping] PRIMARY KEY CLUSTERED 
(
	[RPRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] ADD  CONSTRAINT [DF_T_Role_Page_Rights_Mapping_IsRightActive]  DEFAULT ((0)) FOR [IsRightActive]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] ADD  CONSTRAINT [DF_T_Role_Page_Rights_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] ADD  CONSTRAINT [DF_T_Role_Page_Rights_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Page_Rights] FOREIGN KEY([PR_ID])
REFERENCES [dbo].[T_Page_Rights] ([PR_ID])
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] CHECK CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Page_Rights]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Roles] FOREIGN KEY([R_ID])
REFERENCES [dbo].[T_Roles] ([R_ID])
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] CHECK CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Roles]
GO

CREATE TABLE [dbo].[T_Application_Page_Group_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[APGM_ID] [int] IDENTITY(1,1) NOT NULL,
	[App_ID] [nvarchar](20) NOT NULL,
	[PG_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Application_Page_Group_Mapping] PRIMARY KEY CLUSTERED 
(
	[APGM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Group_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Group_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Application_Page_Group_Mapping_T_Page_Group] FOREIGN KEY([PG_ID])
REFERENCES [dbo].[T_Page_Group] ([PG_ID])
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping] CHECK CONSTRAINT [FK_T_Application_Page_Group_Mapping_T_Page_Group]
GO

CREATE TABLE [dbo].[T_Application_Page_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[APM_ID] [int] IDENTITY(1,1) NOT NULL,
	[Application_MTV_CODE] [nvarchar](20) NOT NULL,
	[P_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Application_Page_Mapping] PRIMARY KEY CLUSTERED 
(
	[APM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Application_Page_Mapping_T_Page] FOREIGN KEY([P_ID])
REFERENCES [dbo].[T_Page] ([P_ID])
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] CHECK CONSTRAINT [FK_T_Application_Page_Mapping_T_Page]
GO


Drop Table [dbo].[T_Docs]
Drop Table [dbo].[T_Errors_List]
Drop Table [dbo].[T_CacheEntries]
Drop Table [dbo].[T_Audit_History]
Drop Table [dbo].[T_Audit_Column]
Drop Table [dbo].[T_Master_Type_Value]
Drop Table [dbo].[T_Master_Type]

CREATE TABLE [dbo].[T_Master_Type](
	[TimeStamp] [timestamp] NOT NULL,
	[MT_ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](150) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Type] PRIMARY KEY CLUSTERED 
(
	[MT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Master_Type] ADD  CONSTRAINT [DF_T_Master_Type_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Master_Type] ADD  CONSTRAINT [DF_T_Master_Type_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_Master_Type_Value](
	[TimeStamp] [timestamp] NOT NULL,
	[MTV_ID] [int] NOT NULL,
	[MTV_CODE] [nvarchar](20) NOT NULL,
	[MT_ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Sub_MTV_ID] [int] NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Type_Value] PRIMARY KEY CLUSTERED 
(
	[MTV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_Sub_MTV_ID]  DEFAULT ((0)) FOR [Sub_MTV_ID]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Master_Type_Value]  WITH CHECK ADD  CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type] FOREIGN KEY([MT_ID])
REFERENCES [dbo].[T_Master_Type] ([MT_ID])
GO
ALTER TABLE [dbo].[T_Master_Type_Value] CHECK CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type]
GO
ALTER TABLE [dbo].[T_Master_Type_Value]  WITH CHECK ADD  CONSTRAINT [const_T_Master_Type_Value_ParentIDCheck] CHECK  ((substring(CONVERT([nvarchar](100),[MTV_ID]),(1),(3))=CONVERT([nvarchar](100),[MT_ID]) AND len(CONVERT([nvarchar](100),[MT_ID]))=(3)))
GO
ALTER TABLE [dbo].[T_Master_Type_Value] CHECK CONSTRAINT [const_T_Master_Type_Value_ParentIDCheck]
GO

CREATE TABLE [dbo].[T_Audit_Column](
	[TimeStamp] [timestamp] NOT NULL,
	[AC_ID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](100) NOT NULL,
	[DbName] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Audit_Column] PRIMARY KEY CLUSTERED 
(
	[AC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_Audit_History](
	[TimeStamp] [timestamp] NOT NULL,
	[AH_ID] [int] IDENTITY(1,1) NOT NULL,
	[AC_ID] [int] NOT NULL,
	[REF_NO] [nvarchar](150) NOT NULL,
	[AuditType_MTV_ID] [int] NOT NULL,
	[RefNo1] [nvarchar](50) NOT NULL,
	[RefNo2] [nvarchar](50) NOT NULL,
	[RefNo3] [nvarchar](50) NOT NULL,
	[OldValueHidden] [nvarchar](2000) NOT NULL,
	[NewValueHidden] [nvarchar](2000) NOT NULL,
	[OldValue] [nvarchar](2000) NOT NULL,
	[NewValue] [nvarchar](2000) NOT NULL,
	[Reason] [nvarchar](1000) NOT NULL,
	[IsAuto] [bit] NOT NULL,
	[Source_MTV_ID] [int] NOT NULL,
	[TriggerDebugInfo] [nvarchar](4000) NULL,
	[ChangedBy] [nvarchar](150) NOT NULL,
	[ChangedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_T_Audit_History] PRIMARY KEY CLUSTERED 
(
	[AH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Audit_History] ADD  CONSTRAINT [DF_T_Audit_History_IsAuto]  DEFAULT ((0)) FOR [IsAuto]
GO
ALTER TABLE [dbo].[T_Audit_History] ADD  CONSTRAINT [DF_T_Audit_History_ChangedOn]  DEFAULT (getutcdate()) FOR [ChangedOn]
GO
ALTER TABLE [dbo].[T_Audit_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Audit_History_T_Audit_Column] FOREIGN KEY([AC_ID])
REFERENCES [dbo].[T_Audit_Column] ([AC_ID])
GO
ALTER TABLE [dbo].[T_Audit_History] CHECK CONSTRAINT [FK_T_Audit_History_T_Audit_Column]
GO
ALTER TABLE [dbo].[T_Audit_History]  WITH CHECK ADD  CONSTRAINT [const_T_Audit_History_AuditType_MTV_ID_Check] CHECK  ((substring(CONVERT([nvarchar](100),[AuditType_MTV_ID]),(1),(3))=(166)))
GO
ALTER TABLE [dbo].[T_Audit_History] CHECK CONSTRAINT [const_T_Audit_History_AuditType_MTV_ID_Check]
GO
ALTER TABLE [dbo].[T_Audit_History]  WITH CHECK ADD  CONSTRAINT [const_T_Audit_History_Source_MTV_ID_Check] CHECK  ((substring(CONVERT([nvarchar](100),[Source_MTV_ID]),(1),(3))=(167)))
GO
ALTER TABLE [dbo].[T_Audit_History] CHECK CONSTRAINT [const_T_Audit_History_Source_MTV_ID_Check]
GO

CREATE TABLE [dbo].[T_CacheEntries](
	[TimeStamp] [timestamp] NOT NULL,
	[CE_ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [varchar](800) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ExpiredOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_T_CacheEntries] PRIMARY KEY CLUSTERED 
(
	[CE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_CacheEntries] ADD  CONSTRAINT [DF_T_CacheEntries_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO

CREATE TABLE [dbo].[T_Errors_List](
	[TimeStamp] [timestamp] NOT NULL,
	[EL_ID] [int] IDENTITY(1,1) NOT NULL,
	[Error_Type_MTV_ID] [int] NOT NULL,
	[Error_Sub_Type_MTV_ID] [int] NOT NULL,
	[Error_ID] [int] NOT NULL,
	[Error_CODE] [nvarchar](20) NOT NULL,
	[Error_Text] [nvarchar](250) NOT NULL,
	[Description_] [nvarchar](1000) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Errors_List] PRIMARY KEY CLUSTERED 
(
	[EL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO

CREATE TABLE [dbo].[T_Docs](
	[TimeStamp] [timestamp] NOT NULL,
	[DOC_ID] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentType_MTV_ID] [int] NOT NULL,
	[OriginalFileName] [nvarchar](250) NULL,
	[ImageName] [nvarchar](100) NOT NULL,
	[Description_] [nvarchar](250) NOT NULL,
	[Path_] [nvarchar](250) NOT NULL,
	[RefNo] [nvarchar](40) NULL,
	[RefNo2] [nvarchar](40) NULL,
	[RefID] [int] NULL,
	[RefID2] [int] NULL,
	[IsPublic] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Docs] PRIMARY KEY CLUSTERED 
(
	[DOC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Docs] ADD  CONSTRAINT [DF_T_Docs_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Docs] ADD  CONSTRAINT [DF_T_Docs_CreatedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

DROP TABLE [dbo].[T_TMS_Chats_Room_Mapping] 
DROP TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping]
DROP TABLE [dbo].[T_TMS_LinkedTasks]
DROP TABLE [dbo].[T_TMS_AssignedTo_List]
DROP TABLE [dbo].[T_TMS_TaskAttachments]
DROP TABLE [dbo].[T_TMS_TaskComments]
DROP TABLE [dbo].[T_TMS_TaskDetail]
DROP TABLE [dbo].[T_TMS_Tasks]


CREATE TABLE [dbo].[T_TMS_Tasks](
	[TimeStamp] [timestamp] NOT NULL,
	[T_ID] [int] IDENTITY(1,1) NOT NULL,
	[TaskName] [nvarchar](250) NOT NULL,
	[Note] [nvarchar](max) NOT NULL,
	[Application_MTV_ID] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__83BB1FB2BE169C24] PRIMARY KEY CLUSTERED 
(
	[T_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_Tasks] ADD  CONSTRAINT [DF_T_Task_Management_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_Tasks] ADD  CONSTRAINT [DF_T_Task_Management_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_TMS_TaskDetail](
	[TimeStamp] [timestamp] NOT NULL,
	[TD_ID] [int] IDENTITY(1,1) NOT NULL,
	[T_ID] [int] NOT NULL,
	[Task_Item] [nvarchar](500) NOT NULL,
	[Task_Item_Detail] [nvarchar](2000) NOT NULL,
	[Task_Start_Date] [date] NULL,
	[Task_End_Date] [date] NULL,
	[Priority_MTV_ID] [int] NOT NULL,
	[Status_MTV_ID] [int] NOT NULL,
	[BUILDCODE] [nvarchar](50) NULL,
	[TaskCategory_MTV_ID] [int] NOT NULL,
	[Review_Date] [date] NULL,
	[ETA_Date] [date] NULL,
	[IsPrivate] [bit] NOT NULL,
	[LeadAssignTo] [nvarchar](150) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
	[Application_URL] [int] NULL,
 CONSTRAINT [PK__T_TMS_Ta__B2EE46BBFFF3434D] PRIMARY KEY CLUSTERED 
(
	[TD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] ADD  CONSTRAINT [DF_T_TMS_TaskDetail_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] ADD  CONSTRAINT [DF_T_TMS_TaskDetail_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] ADD  CONSTRAINT [DF__T_TMS_Tas__Appli__4B42F62C]  DEFAULT ((0)) FOR [Application_URL]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail]  WITH CHECK ADD  CONSTRAINT [FK__T_TMS_Task__T_ID__6CD8F421] FOREIGN KEY([T_ID])
REFERENCES [dbo].[T_TMS_Tasks] ([T_ID])
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] CHECK CONSTRAINT [FK__T_TMS_Task__T_ID__6CD8F421]
GO

CREATE TABLE [dbo].[T_TMS_TaskComments](
	[TimeStamp] [timestamp] NOT NULL,
	[TC_ID] [int] IDENTITY(1,1) NOT NULL,
	[TD_ID] [int] NOT NULL,
	[CommentText] [nvarchar](2000) NOT NULL,
	[Application_URL] [int] NOT NULL,
	[Task_Start_Date] [date] NULL,
	[Task_End_Date] [date] NULL,
	[Priority_MTV_ID] [int] NOT NULL,
	[Status_MTV_ID] [int] NOT NULL,
	[BUILDCODE] [nvarchar](50) NULL,
	[TaskCategory_MTV_ID] [int] NOT NULL,
	[Review_Date] [date] NULL,
	[ETA_Date] [date] NULL,
	[IsPrivate] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__2A3483DE61E78521] PRIMARY KEY CLUSTERED 
(
	[TC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_TaskComments] ADD  CONSTRAINT [DF_T_TMS_TaskComments_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskComments] ADD  CONSTRAINT [DF_T_TMS_TaskComments_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskComments]  WITH CHECK ADD  CONSTRAINT [FK_T_TMS_TaskComments_T_TMS_TaskDetail] FOREIGN KEY([TD_ID])
REFERENCES [dbo].[T_TMS_TaskDetail] ([TD_ID])
GO
ALTER TABLE [dbo].[T_TMS_TaskComments] CHECK CONSTRAINT [FK_T_TMS_TaskComments_T_TMS_TaskDetail]
GO

CREATE TABLE [dbo].[T_TMS_TaskAttachments](
	[TimeStamp] [timestamp] NOT NULL,
	[TA_ID] [int] IDENTITY(1,1) NOT NULL,
	[OriginalFileName] [nvarchar](250) NOT NULL,
	[FileName] [nvarchar](50) NOT NULL,
	[FileExt] [nvarchar](10) NOT NULL,
	[Path] [nvarchar](500) NOT NULL,
	[DocumentType_MTV_ID] [int] NOT NULL,
	[AttachmentType_MTV_ID] [int] NOT NULL,
	[REFID1] [int] NOT NULL,
	[REFID2] [int] NULL,
	[REFID3] [int] NULL,
	[REFID4] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__2F5D5550E47FC396] PRIMARY KEY CLUSTERED 
(
	[TA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_TaskAttachments] ADD  CONSTRAINT [DF_T_TMS_TaskAttachments_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskAttachments] ADD  CONSTRAINT [DF_T_TMS_TaskAttachments_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO

CREATE TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[TATM_ID] [int] IDENTITY(1,1) NOT NULL,
	[TD_ID] [int] NOT NULL,
	[AssignToType_MTV_CODE] [nvarchar](20) NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[AssignedTo] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__0342D215041BAEEC] PRIMARY KEY CLUSTERED 
(
	[TATM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping] ADD  CONSTRAINT [DF_T_TMS_TaskAssignedTo_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping] ADD  CONSTRAINT [DF_T_TMS_TaskAssignedTo_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_TMS_TaskAssignedTo_Mapping_T_TMS_TaskDetail] FOREIGN KEY([TD_ID])
REFERENCES [dbo].[T_TMS_TaskDetail] ([TD_ID])
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping] CHECK CONSTRAINT [FK_T_TMS_TaskAssignedTo_Mapping_T_TMS_TaskDetail]
GO

CREATE TABLE [dbo].[T_TMS_LinkedTasks](
	[TimeStamp] [timestamp] NOT NULL,
	[Parent_TD] [int] NOT NULL,
	[LinkedTask_TD] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](300) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](300) NULL,
	[ModifiedOn] [datetime] NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[T_TMS_AssignedTo_List](
	[TimeStamp] [timestamp] NOT NULL,
	[TAL_ID] [int] IDENTITY(1,1) NOT NULL,
	[AssignToType_MTV_CODE] [nvarchar](20) NOT NULL,
	[AssignedTo] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_TMS_AssignedTo_List] PRIMARY KEY CLUSTERED 
(
	[TAL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_AssignedTo_List] ADD  CONSTRAINT [DF_T_TMS_AssignedTo_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_AssignedTo_List] ADD  CONSTRAINT [DF_T_TMS_AssignedTo_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO



DROP TABLE [dbo].[T_Chats_User_Mapping] 
DROP TABLE [dbo].[T_Chats] 
DROP TABLE [dbo].[T_Chat_Room_User_Mapping] 
DROP TABLE [dbo].[T_Chat_Room] 


CREATE TABLE [dbo].[T_Chat_Room](
	[TimeStamp] [timestamp] NOT NULL,
	[CR_ID] [int] IDENTITY(1,1) NOT NULL Primary Key,
	[Room_Name] [nvarchar](150) NOT NULL,
	[Room_Type_MTV_CODE] nvarchar(20) NOT NULL,
	[IsPublic] [bit] Not Null,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
ALTER TABLE [dbo].[T_Chat_Room] ADD  CONSTRAINT [DF_T_Chat_Room_IsPublic]  DEFAULT ((0)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Chat_Room] ADD  CONSTRAINT [DF_T_Chat_Room_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chat_Room] ADD  CONSTRAINT [DF_T_Chat_Room_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO


CREATE TABLE [dbo].[T_Chat_Room_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[CRUM_ID] [int] IDENTITY(1,1) NOT NULL Primary Key,
	[CR_ID] [int] NOT NULL FOREIGN KEY ([CR_ID]) REFERENCES [T_Chat_Room]([CR_ID]),
	[UserName] [nvarchar](150) NOT NULL,
	[IsHistoryAllowed] [bit] NOT NULL,
	[IsNotificationEnabled] [bit] NOT NULL,
	[IsAdmin] [bit] NOT NULL,
	[IsUserAddedAllowed] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[IsOnline] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsHistoryAllowed]  DEFAULT ((1)) FOR [IsHistoryAllowed]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsNotificationEnabled]  DEFAULT ((1)) FOR [IsNotificationEnabled]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsAdmin]  DEFAULT ((0)) FOR [IsAdmin]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsUserAddedAllowed]  DEFAULT ((1)) FOR [IsUserAddedAllowed]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsOnline]  DEFAULT ((0)) FOR [IsOnline]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO


CREATE TABLE [dbo].[T_Chats](
	[TimeStamp] [timestamp] NOT NULL,
	[C_ID] [int] IDENTITY(1,1) NOT NULL Primary Key,
	[Parent_C_ID] [int] NOT NULL,
	[CRUM_ID] [int] NOT NULL FOREIGN KEY ([CRUM_ID]) REFERENCES [T_Chat_Room_User_Mapping]([CRUM_ID]),
	[Send_UserName] [nvarchar](150) NOT NULL,
	[Parent_C_ID_Image] [nvarchar](max) NULL,
	[Message] [nvarchar](max) NULL,
	[Attachment_Path] [nvarchar](250) NULL,
	[Attachment_Ext] [nvarchar](10) NULL,
	[Attachment_Name] [nvarchar](150) NULL,
	[Attachment_FileSize] BIGINT NULL,
	[IsEdited] [bit] NOT NULL,
	[EditedOn] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_IsEdited]  DEFAULT ((0)) FOR [IsEdited]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO


CREATE TABLE [dbo].[T_Chats_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[CUM_ID] [int] IDENTITY(1,1) NOT NULL Primary Key,
	[C_ID] [int] NOT NULL FOREIGN KEY ([C_ID]) REFERENCES [T_Chats]([C_ID]),
	[Recieve_UserName] [nvarchar](150) NOT NULL,
	[IsRead] [bit] NOT NULL,
	[IsBookmark] [bit] NOT NULL,
	[IsFlag] [bit] NOT NULL,
	[Read_At] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsRead]  DEFAULT ((0)) FOR [IsRead]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsBookmark]  DEFAULT ((0)) FOR [IsBookmark]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsFlag]  DEFAULT ((0)) FOR [IsFlag]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO


CREATE TABLE [dbo].[T_TMS_Chats_Room_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[TCRM_ID] [int] IDENTITY(1,1) NOT NULL Primary Key,
	[TD_ID] [int] NOT NULL FOREIGN KEY (TD_ID) REFERENCES [T_TMS_TaskDetail](TD_ID),
	[CR_ID] [int] NOT NULL FOREIGN KEY ([CR_ID]) REFERENCES [T_Chat_Room]([CR_ID]),
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
)
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping] ADD  CONSTRAINT [DF_T_TMS_Chats_Room_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping] ADD  CONSTRAINT [DF_T_TMS_Chats_Room_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO