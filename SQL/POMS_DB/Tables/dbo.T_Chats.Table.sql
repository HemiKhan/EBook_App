USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Chats]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Chats](
	[TimeStamp] [timestamp] NOT NULL,
	[C_ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent_C_ID] [int] NOT NULL,
	[CRUM_ID] [int] NOT NULL,
	[Send_UserName] [nvarchar](150) NOT NULL,
	[Parent_C_ID_Image] [nvarchar](max) NULL,
	[Message] [nvarchar](max) NULL,
	[Attachment_Path] [nvarchar](250) NULL,
	[Attachment_Ext] [nvarchar](10) NULL,
	[Attachment_Name] [nvarchar](150) NULL,
	[Attachment_FileSize] [bigint] NULL,
	[IsEdited] [bit] NOT NULL,
	[EditedOn] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[C_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_IsEdited]  DEFAULT ((0)) FOR [IsEdited]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Chats]  WITH CHECK ADD FOREIGN KEY([CRUM_ID])
REFERENCES [dbo].[T_Chat_Room_User_Mapping] ([CRUM_ID])
GO
