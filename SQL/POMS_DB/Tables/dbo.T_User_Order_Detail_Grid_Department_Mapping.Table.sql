USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_User_Order_Detail_Grid_Department_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Order_Detail_Grid_Department_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[UODGDM_ID] [int] NOT NULL,
	[ODGDM_ID] [int] NOT NULL,
	[USERNAME] [nvarchar](150) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsExpand] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Order_Detail_Grid_Department_Mapping] PRIMARY KEY CLUSTERED 
(
	[UODGDM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_User_Order_Detail_Grid_Department_Mapping] ADD  CONSTRAINT [DF_T_User_Order_Detail_Grid_Department_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_User_Order_Detail_Grid_Department_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_User_Order_Detail_Grid_Department_Mapping_T_Order_Detail_Grid_Department_Mapping] FOREIGN KEY([ODGDM_ID])
REFERENCES [dbo].[T_Order_Detail_Grid_Department_Mapping] ([ODGDM_ID])
GO
ALTER TABLE [dbo].[T_User_Order_Detail_Grid_Department_Mapping] CHECK CONSTRAINT [FK_T_User_Order_Detail_Grid_Department_Mapping_T_Order_Detail_Grid_Department_Mapping]
GO
