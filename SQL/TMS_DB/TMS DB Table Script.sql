USE [Ebook_DB]

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
