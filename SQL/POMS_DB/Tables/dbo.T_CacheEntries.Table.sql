USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_CacheEntries]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_CacheEntries](
	[TimeStamp] [timestamp] NOT NULL,
	[CE_ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [varchar](800) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ExpiredOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_T_CacheEntries] PRIMARY KEY CLUSTERED 
(
	[CE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_CacheEntries] ADD  CONSTRAINT [DF_T_CacheEntries_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
