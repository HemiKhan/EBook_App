USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Service_Type]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Service_Type](
	[TimeStamp] [timestamp] NOT NULL,
	[ST_CODE] [nvarchar](20) NOT NULL,
	[ServiceName] [nvarchar](100) NOT NULL,
	[Type_MTV_ID] [int] NOT NULL,
	[Sort_] [tinyint] NOT NULL,
	[IsAllowed] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Service_Type] PRIMARY KEY CLUSTERED 
(
	[ST_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Service_Type] ADD  CONSTRAINT [DF_T_Service_Type_IsAllowed]  DEFAULT ((1)) FOR [IsAllowed]
GO
ALTER TABLE [dbo].[T_Service_Type] ADD  CONSTRAINT [DF_T_Service_Type_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Service_Type] ADD  CONSTRAINT [DF_T_Service_Type_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
