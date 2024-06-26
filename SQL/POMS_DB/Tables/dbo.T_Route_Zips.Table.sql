USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Route_Zips]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Route_Zips](
	[TimeStamp] [timestamp] NOT NULL,
	[RZ_ID] [int] IDENTITY(1,1) NOT NULL,
	[RL_ID] [int] NOT NULL,
	[ZIP_CODE] [nvarchar](10) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Route_Zips] PRIMARY KEY CLUSTERED 
(
	[RZ_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Route_Zips] ADD  CONSTRAINT [DF_T_Route_Zips_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Route_Zips] ADD  CONSTRAINT [DF_T_Route_Zips_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Route_Zips]  WITH CHECK ADD  CONSTRAINT [FK_T_Route_Zips_T_Route_List] FOREIGN KEY([RL_ID])
REFERENCES [dbo].[T_Route_List] ([RL_ID])
GO
ALTER TABLE [dbo].[T_Route_Zips] CHECK CONSTRAINT [FK_T_Route_Zips_T_Route_List]
GO
