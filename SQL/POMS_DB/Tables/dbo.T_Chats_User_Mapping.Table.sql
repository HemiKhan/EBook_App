USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Chats_User_Mapping]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Chats_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[CUM_ID] [int] IDENTITY(1,1) NOT NULL,
	[C_ID] [int] NOT NULL,
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
PRIMARY KEY CLUSTERED 
(
	[CUM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
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
ALTER TABLE [dbo].[T_Chats_User_Mapping]  WITH CHECK ADD FOREIGN KEY([C_ID])
REFERENCES [dbo].[T_Chats] ([C_ID])
GO
