USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Special_Instruction]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Special_Instruction](
	[TimeStamp] [timestamp] NOT NULL,
	[OSI_ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[InstructionType_MTV_ID] [int] NOT NULL,
	[Instruction] [nvarchar](1000) NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Sales_Order_Special_Instruction] PRIMARY KEY CLUSTERED 
(
	[OSI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Special_Instruction] ADD  CONSTRAINT [DF_T_Sales_Order_Special_Instruction_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
