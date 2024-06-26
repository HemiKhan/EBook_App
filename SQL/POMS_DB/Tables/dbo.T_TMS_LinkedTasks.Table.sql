USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_TMS_LinkedTasks]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
