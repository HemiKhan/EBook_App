USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_TMS_Chats_Room_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_Chats_Room_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[TCRM_ID] [int] IDENTITY(1,1) NOT NULL,
	[TD_ID] [int] NOT NULL,
	[CR_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[TCRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping] ADD  CONSTRAINT [DF_T_TMS_Chats_Room_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping] ADD  CONSTRAINT [DF_T_TMS_Chats_Room_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping]  WITH CHECK ADD FOREIGN KEY([CR_ID])
REFERENCES [dbo].[T_Chat_Room] ([CR_ID])
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping]  WITH CHECK ADD FOREIGN KEY([TD_ID])
REFERENCES [dbo].[T_TMS_TaskDetail] ([TD_ID])
GO
