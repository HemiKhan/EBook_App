USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Generate_EstimateInvoiceID]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Generate_EstimateInvoiceID](
	[EstimateInvoice_ID] [bigint] IDENTITY(10000000,1) NOT NULL,
	[IsGenerate] [bit] NOT NULL,
 CONSTRAINT [PK_T_Generate_EstimateInvoiceID] PRIMARY KEY CLUSTERED 
(
	[EstimateInvoice_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
