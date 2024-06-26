USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Seller_Allocation_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Seller_Allocation_List](
	[TimeStamp] [timestamp] NOT NULL,
	[SAL_ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[AML_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Seller_Allocation_List] PRIMARY KEY CLUSTERED 
(
	[SAL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Seller_Allocation_List] ADD  CONSTRAINT [DF_T_Seller_Allocation_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Seller_Allocation_List] ADD  CONSTRAINT [DF_T_Seller_Allocation_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Seller_Allocation_List]  WITH CHECK ADD  CONSTRAINT [FK_T_Seller_Allocation_List_T_Account_Manager_List] FOREIGN KEY([AML_ID])
REFERENCES [dbo].[T_Account_Manager_List] ([AML_ID])
GO
ALTER TABLE [dbo].[T_Seller_Allocation_List] CHECK CONSTRAINT [FK_T_Seller_Allocation_List_T_Account_Manager_List]
GO
