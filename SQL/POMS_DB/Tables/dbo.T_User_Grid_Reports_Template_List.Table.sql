USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_User_Grid_Reports_Template_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Grid_Reports_Template_List](
	[TimeStamp] [timestamp] NOT NULL,
	[UGRTL_ID] [int] IDENTITY(1,1) NOT NULL,
	[GRL_ID] [int] NOT NULL,
	[USERNAME] [nvarchar](150) NOT NULL,
	[GUID_] [nvarchar](36) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Grid_Reports_Template_List] PRIMARY KEY CLUSTERED 
(
	[UGRTL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_User_Grid_Reports_Template_List] ADD  CONSTRAINT [DF_T_User_Grid_Reports_Template_List_GUID_]  DEFAULT (lower(newid())) FOR [GUID_]
GO
ALTER TABLE [dbo].[T_User_Grid_Reports_Template_List] ADD  CONSTRAINT [DF_T_User_Grid_Reports_Template_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Grid_Reports_Template_List] ADD  CONSTRAINT [DF_T_User_Grid_Reports_Template_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
