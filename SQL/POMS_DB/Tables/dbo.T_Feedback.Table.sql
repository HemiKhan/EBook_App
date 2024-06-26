USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Feedback]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Feedback](
	[TimeStamp] [datetime] NULL,
	[FDB_ID] [int] IDENTITY(1,1) NOT NULL,
	[ImageData] [nvarchar](4000) NULL,
	[MessageData] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_Feedba__5F7254CCF1A1F180] PRIMARY KEY CLUSTERED 
(
	[FDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
