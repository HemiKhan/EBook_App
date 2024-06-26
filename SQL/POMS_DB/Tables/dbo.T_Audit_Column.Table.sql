USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Audit_Column]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Audit_Column](
	[TimeStamp] [timestamp] NOT NULL,
	[AC_ID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](100) NOT NULL,
	[DbName] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Audit_Column] PRIMARY KEY CLUSTERED 
(
	[AC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
