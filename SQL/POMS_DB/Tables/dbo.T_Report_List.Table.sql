USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Report_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_List](
	[TimeStamp] [timestamp] NOT NULL,
	[RL_ID] [int] IDENTITY(1,1) NOT NULL,
	[RSP_ID] [int] NOT NULL,
	[ReportName] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[IsGeneral] [bit] NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Reports_List] PRIMARY KEY CLUSTERED 
(
	[RL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_IsGeneral]  DEFAULT ((0)) FOR [IsGeneral]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_IsPublic]  DEFAULT ((0)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Report_List]  WITH CHECK ADD  CONSTRAINT [FK_T_Report_List_T_Report_Store_Procedure] FOREIGN KEY([RSP_ID])
REFERENCES [dbo].[T_Report_Store_Procedure] ([RSP_ID])
GO
ALTER TABLE [dbo].[T_Report_List] CHECK CONSTRAINT [FK_T_Report_List_T_Report_Store_Procedure]
GO
