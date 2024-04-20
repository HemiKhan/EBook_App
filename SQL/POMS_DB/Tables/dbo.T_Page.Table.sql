USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Page]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Page](
	[TimeStamp] [timestamp] NOT NULL,
	[P_ID] [int] NOT NULL,
	[PG_ID] [int] NOT NULL,
	[PageName] [nvarchar](50) NOT NULL,
	[PageURL] [nvarchar](250) NOT NULL,
	[Application_MTV_ID] [int] NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page] PRIMARY KEY CLUSTERED 
(
	[P_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_Application_MTV_ID]  DEFAULT ((148100)) FOR [Application_MTV_ID]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Page]  WITH CHECK ADD  CONSTRAINT [FK_T_Page_T_Page_Group] FOREIGN KEY([PG_ID])
REFERENCES [dbo].[T_Page_Group] ([PG_ID])
GO
ALTER TABLE [dbo].[T_Page] CHECK CONSTRAINT [FK_T_Page_T_Page_Group]
GO
ALTER TABLE [dbo].[T_Page]  WITH CHECK ADD  CONSTRAINT [const_T_Page_Value_ParentIDCheck] CHECK  ((format([PG_ID],'000')=left(format(CONVERT([int],left([P_ID],len([PG_ID]))),'000'),(3))))
GO
ALTER TABLE [dbo].[T_Page] CHECK CONSTRAINT [const_T_Page_Value_ParentIDCheck]
GO
