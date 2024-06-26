USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Report_Column_Fields]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_Column_Fields](
	[TimeStamp] [timestamp] NOT NULL,
	[RCF_ID] [int] IDENTITY(1,1) NOT NULL,
	[RL_ID] [int] NOT NULL,
	[ColumnName] [nvarchar](50) NOT NULL,
	[Position] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Report_Column_Fields] PRIMARY KEY CLUSTERED 
(
	[RCF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Report_Column_Fields] ADD  CONSTRAINT [DF_T_Report_Column_Fields_Position]  DEFAULT ((0)) FOR [Position]
GO
ALTER TABLE [dbo].[T_Report_Column_Fields] ADD  CONSTRAINT [DF_T_Report_Column_Fields_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_Column_Fields] ADD  CONSTRAINT [DF_T_Report_Column_Fields_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Report_Column_Fields]  WITH CHECK ADD  CONSTRAINT [FK_T_Report_Column_Fields_T_Reports_List] FOREIGN KEY([RL_ID])
REFERENCES [dbo].[T_Report_List] ([RL_ID])
GO
ALTER TABLE [dbo].[T_Report_Column_Fields] CHECK CONSTRAINT [FK_T_Report_Column_Fields_T_Reports_List]
GO
