USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Chat_Room_User_Mapping]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Chat_Room_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[CRUM_ID] [int] IDENTITY(1,1) NOT NULL,
	[CR_ID] [int] NOT NULL,
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
PRIMARY KEY CLUSTERED 
(
	[CRUM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
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
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping]  WITH CHECK ADD FOREIGN KEY([CR_ID])
REFERENCES [dbo].[T_Chat_Room] ([CR_ID])
GO
