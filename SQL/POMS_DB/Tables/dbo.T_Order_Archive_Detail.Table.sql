USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Archive_Detail]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Archive_Detail](
	[TimeStamp] [timestamp] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[ORDER_CODE_GUID] [nvarchar](36) NOT NULL,
	[TRACKING_NO] [nvarchar](40) NOT NULL,
	[Order_ArchiveDate] [date] NULL,
	[Order_Detail_ArchiveDate] [date] NULL,
	[Order_Additional_Info_ArchiveDate] [date] NULL,
	[Order_Items_ArchiveDate] [date] NULL,
	[Order_Items_Additional_Info_ArchiveDate] [date] NULL,
	[Order_Access_Log_ArchiveDate] [date] NULL,
	[Order_Audit_History_ArchiveDate] [date] NULL,
	[Order_Client_Identifier_ArchiveDate] [date] NULL,
	[Order_Comments_ArchiveDate] [date] NULL,
	[Order_Docs_ArchiveDate] [date] NULL,
	[Order_Events_ArchiveDate] [date] NULL,
	[Order_Events_List_ArchiveDate] [date] NULL,
	[Order_Item_Scans_ArchiveDate] [date] NULL,
	[Order_Related_Tickets_ArchiveDate] [date] NULL,
	[Order_Special_Instruction_ArchiveDate] [date] NULL,
	[Order_Special_Service_ArchiveDate] [date] NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Archive_Detail] PRIMARY KEY CLUSTERED 
(
	[ORDER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Archive_Detail] ADD  CONSTRAINT [DF_T_Order_Archive_Detail_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
