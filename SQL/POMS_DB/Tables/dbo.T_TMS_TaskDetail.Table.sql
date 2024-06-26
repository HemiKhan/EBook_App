USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_TMS_TaskDetail]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
