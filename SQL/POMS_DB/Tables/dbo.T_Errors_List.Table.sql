USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Errors_List]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Errors_List](
	[TimeStamp] [timestamp] NOT NULL,
	[EL_ID] [int] IDENTITY(1,1) NOT NULL,
	[Error_Type_MTV_ID] [int] NOT NULL,
	[Error_Sub_Type_MTV_ID] [int] NOT NULL,
	[Error_ID] [int] NOT NULL,
	[Error_CODE] [nvarchar](20) NOT NULL,
	[Error_Text] [nvarchar](250) NOT NULL,
	[Description_] [nvarchar](1000) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Errors_List] PRIMARY KEY CLUSTERED 
(
	[EL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
