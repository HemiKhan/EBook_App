USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_User_Grid_Report_Columns]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Grid_Report_Columns](
	[TimeStamp] [timestamp] NOT NULL,
	[UGRC_ID] [int] IDENTITY(1,1) NOT NULL,
	[USERNAME] [nvarchar](150) NOT NULL,
	[UGRTL_ID] [int] NOT NULL,
	[GRC_ID] [int] NOT NULL,
	[IsHidden] [bit] NOT NULL,
	[IsChecked] [bit] NOT NULL,
	[SortPosition] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Grid_Report_Columns] PRIMARY KEY CLUSTERED 
(
	[UGRC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_User_Grid_Report_Columns] ADD  CONSTRAINT [DF_T_User_Grid_Report_Columns_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Grid_Report_Columns] ADD  CONSTRAINT [DF_T_User_Grid_Report_Columns_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_User_Grid_Report_Columns]  WITH CHECK ADD  CONSTRAINT [FK_T_User_Grid_Report_Columns_T_Grid_Report_Columns] FOREIGN KEY([GRC_ID])
REFERENCES [dbo].[T_Grid_Report_Columns] ([GRC_ID])
GO
ALTER TABLE [dbo].[T_User_Grid_Report_Columns] CHECK CONSTRAINT [FK_T_User_Grid_Report_Columns_T_Grid_Report_Columns]
GO
ALTER TABLE [dbo].[T_User_Grid_Report_Columns]  WITH CHECK ADD  CONSTRAINT [FK_T_User_Grid_Report_Columns_T_Grid_Reports_List] FOREIGN KEY([UGRTL_ID])
REFERENCES [dbo].[T_User_Grid_Reports_Template_List] ([UGRTL_ID])
GO
ALTER TABLE [dbo].[T_User_Grid_Report_Columns] CHECK CONSTRAINT [FK_T_User_Grid_Report_Columns_T_Grid_Reports_List]
GO
