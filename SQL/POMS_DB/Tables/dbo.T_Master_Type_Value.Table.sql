USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Master_Type_Value]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_Type_Value](
	[TimeStamp] [timestamp] NOT NULL,
	[MTV_ID] [int] NOT NULL,
	[MTV_CODE] [nvarchar](20) NOT NULL,
	[MT_ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Sub_MTV_ID] [int] NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Type_Value] PRIMARY KEY CLUSTERED 
(
	[MTV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_Sub_MTV_ID]  DEFAULT ((0)) FOR [Sub_MTV_ID]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Master_Type_Value]  WITH CHECK ADD  CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type] FOREIGN KEY([MT_ID])
REFERENCES [dbo].[T_Master_Type] ([MT_ID])
GO
ALTER TABLE [dbo].[T_Master_Type_Value] CHECK CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type]
GO
ALTER TABLE [dbo].[T_Master_Type_Value]  WITH CHECK ADD  CONSTRAINT [const_T_Master_Type_Value_ParentIDCheck] CHECK  ((substring(CONVERT([nvarchar](100),[MTV_ID]),(1),(3))=CONVERT([nvarchar](100),[MT_ID]) AND len(CONVERT([nvarchar](100),[MT_ID]))=(3)))
GO
ALTER TABLE [dbo].[T_Master_Type_Value] CHECK CONSTRAINT [const_T_Master_Type_Value_ParentIDCheck]
GO
