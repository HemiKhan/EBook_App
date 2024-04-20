USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Report_Store_Procedure_Where_Clause]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_Store_Procedure_Where_Clause](
	[TimeStamp] [timestamp] NOT NULL,
	[RSPWC_ID] [int] IDENTITY(1,1) NOT NULL,
	[RSPF_ID] [int] NOT NULL,
	[WhereClause_MTV_CODE] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[Limit] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Report_Store_Procedure_Where_Clause] PRIMARY KEY CLUSTERED 
(
	[RSPWC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure_Where_Clause] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_Where_Clause_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure_Where_Clause] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_Where_Clause_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
