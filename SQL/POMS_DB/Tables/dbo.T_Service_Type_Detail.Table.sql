USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Service_Type_Detail]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Service_Type_Detail](
	[TimeStamp] [timestamp] NOT NULL,
	[STD_ID] [int] IDENTITY(1,1) NOT NULL,
	[SST_CODE] [nvarchar](20) NOT NULL,
	[ST_CODE] [nvarchar](20) NOT NULL,
	[ServiceDetail] [nvarchar](100) NOT NULL,
	[Sort_] [tinyint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Service_Type_Detail] PRIMARY KEY CLUSTERED 
(
	[STD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Service_Type_Detail] ADD  CONSTRAINT [DF_T_Service_Type_Detail_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Service_Type_Detail] ADD  CONSTRAINT [DF_T_Service_Type_Detail_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
