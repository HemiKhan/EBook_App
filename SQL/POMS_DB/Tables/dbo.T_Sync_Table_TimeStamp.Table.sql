USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Sync_Table_TimeStamp]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Sync_Table_TimeStamp](
	[TableName] [nvarchar](250) NOT NULL,
	[TimeStamp] [varbinary](50) NULL
) ON [PRIMARY]
GO
