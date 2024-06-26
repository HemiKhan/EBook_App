USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Page_Rights]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Page_Rights](
	[TimeStamp] [timestamp] NOT NULL,
	[PR_ID] [int] NOT NULL,
	[P_ID] [int] NOT NULL,
	[PR_CODE] [nvarchar](50) NOT NULL,
	[PageRightName] [nvarchar](50) NOT NULL,
	[PageRightType_MTV_CODE] [nvarchar](20) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page_Rights] PRIMARY KEY CLUSTERED 
(
	[PR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Page_Rights]  WITH CHECK ADD  CONSTRAINT [FK_T_Page_Rights_T_Page] FOREIGN KEY([P_ID])
REFERENCES [dbo].[T_Page] ([P_ID])
GO
ALTER TABLE [dbo].[T_Page_Rights] CHECK CONSTRAINT [FK_T_Page_Rights_T_Page]
GO
ALTER TABLE [dbo].[T_Page_Rights]  WITH CHECK ADD  CONSTRAINT [const_T_Page_Rights_Value_ParentIDCheck] CHECK  ((substring(CONVERT([nvarchar](100),[PR_ID]),(1),len(CONVERT([nvarchar](100),[P_ID])))=CONVERT([nvarchar](100),[P_ID])))
GO
ALTER TABLE [dbo].[T_Page_Rights] CHECK CONSTRAINT [const_T_Page_Rights_Value_ParentIDCheck]
GO
