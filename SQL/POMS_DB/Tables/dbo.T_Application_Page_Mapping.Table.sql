USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Application_Page_Mapping]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Application_Page_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[APM_ID] [int] IDENTITY(1,1) NOT NULL,
	[Application_MTV_CODE] [nvarchar](20) NOT NULL,
	[P_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Application_Page_Mapping] PRIMARY KEY CLUSTERED 
(
	[APM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Application_Page_Mapping_T_Page] FOREIGN KEY([P_ID])
REFERENCES [dbo].[T_Page] ([P_ID])
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] CHECK CONSTRAINT [FK_T_Application_Page_Mapping_T_Page]
GO
