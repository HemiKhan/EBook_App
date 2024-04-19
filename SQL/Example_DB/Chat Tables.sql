
DROP TABLE [dbo].[T_TMS_Chats_Room_Mapping] 
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


--/*
INSERT INTO [dbo].[T_Chat_Room] (Room_Name,Room_Type_MTV_CODE,IsActive,AddedOn,AddedBy) VALUES ('Public Chat','PUBLIC',1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room] (Room_Name,Room_Type_MTV_CODE,IsActive,AddedOn,AddedBy) VALUES ('TMS','GROUP',1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room] (Room_Name,Room_Type_MTV_CODE,IsActive,AddedOn,AddedBy) VALUES ('HAMMAS.KHAN - IHTISHAM.ULHAQ','PRIVATE',1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room] (Room_Name,Room_Type_MTV_CODE,IsActive,AddedOn,AddedBy) VALUES ('HAMMAS.KHAN - BABAR.ALI','PRIVATE',1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room] (Room_Name,Room_Type_MTV_CODE,IsActive,AddedOn,AddedBy) VALUES ('IHTISHAM.ULHAQ - BABAR.ALI','PRIVATE',1,GETUTCDATE(),'IHTISHAM.ULHAQ')


INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (1,'All',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')

INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (2,'HAMMAS.KHAN',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (2,'IHTISHAM.ULHAQ',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (2,'BABAR.ALI',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')

INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (3,'HAMMAS.KHAN',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (3,'IHTISHAM.ULHAQ',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')

INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (4,'HAMMAS.KHAN',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (4,'BABAR.ALI',1,1,1,1,1,1,1,GETUTCDATE(),'HAMMAS.KHAN')

INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (5,'IHTISHAM.ULHAQ',1,1,1,1,1,1,1,GETUTCDATE(),'IHTISHAM.ULHAQ')
INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedOn,AddedBy) VALUES (5,'BABAR.ALI',1,1,1,1,1,1,1,GETUTCDATE(),'IHTISHAM.ULHAQ')


INSERT INTO [dbo].[T_Chats] (Parent_C_ID,CRUM_ID,Send_UserName,Message,Attachment_Path,IsActive,AddedOn,AddedBy) VALUES (0,2,'HAMMAS.KHAN','Hi! Babar & Ihtisham',null,1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (1, 'IHTISHAM.ULHAQ', 0, 0, 0, NULL, 1, 'HAMMAS.KHAN', GETUTCDATE())
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (1, 'BABAR.ALI', 0, 0, 0, NULL, 1, 'HAMMAS.KHAN', GETUTCDATE())

INSERT INTO [dbo].[T_Chats] (Parent_C_ID,CRUM_ID,Send_UserName,Message,Attachment_Path,IsActive,AddedOn,AddedBy) VALUES (0,3,'IHTISHAM.ULHAQ','Hi! Hammas & Babar',null,1,GETUTCDATE(),'IHTISHAM.ULHAQ')
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (2, 'HAMMAS.KHAN', 0, 0, 0, NULL, 1, 'IHTISHAM.ULHAQ', GETUTCDATE())
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (2, 'BABAR.ALI', 0, 0, 0, NULL, 1, 'IHTISHAM.ULHAQ', GETUTCDATE())

INSERT INTO [dbo].[T_Chats] (Parent_C_ID,CRUM_ID,Send_UserName,Message,Attachment_Path,IsActive,AddedOn,AddedBy) VALUES (0,4,'BABAR.ALI','Hi! Hammas & Ihtisham',null,1,GETUTCDATE(),'BABAR.ALI')
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (3, 'IHTISHAM.ULHAQ', 0, 0, 0, NULL, 1, 'BABAR.ALI', GETUTCDATE())
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (3, 'HAMMAS.KHAN', 0, 0, 0, NULL, 1, 'BABAR.ALI', GETUTCDATE())

INSERT INTO [dbo].[T_Chats] (Parent_C_ID,CRUM_ID,Send_UserName,Message,Attachment_Path,IsActive,AddedOn,AddedBy) VALUES (0,5,'HAMMAS.KHAN','Hi! Ihtisham',null,1,GETUTCDATE(),'HAMMAS.KHAN')
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (4, 'IHTISHAM.ULHAQ', 0, 0, 0, NULL, 1, 'HAMMAS.KHAN', GETUTCDATE())

INSERT INTO [dbo].[T_Chats] (Parent_C_ID,CRUM_ID,Send_UserName,Message,Attachment_Path,IsActive,AddedOn,AddedBy) VALUES (0,6,'IHTISHAM.ULHAQ','Hi! Hammas',null,1,GETUTCDATE(),'IHTISHAM.ULHAQ')
INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) VALUES (5, 'HAMMAS.KHAN', 0, 0, 0, NULL, 1, 'IHTISHAM.ULHAQ', GETUTCDATE())
--*/

SELECT * FROM [dbo].[T_Chat_Room] WITH (NOLOCK)
SELECT * FROM [dbo].[T_Chat_Room_User_Mapping] WITH (NOLOCK)
SELECT * FROM [dbo].[T_Chats] WITH (NOLOCK)
SELECT * FROM [dbo].[T_Chats_User_Mapping] WITH (NOLOCK)
SELECT * FROM [dbo].[T_TMS_Chats_Room_Mapping] WITH (NOLOCK)