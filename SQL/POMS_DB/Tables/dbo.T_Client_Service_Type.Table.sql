USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Client_Service_Type]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Client_Service_Type](
	[TimeStamp] [timestamp] NOT NULL,
	[ST_CODE] [nvarchar](20) NOT NULL,
	[SELLER_CODE] [nvarchar](20) NOT NULL,
	[IsAllowed] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Client_Service_Level] PRIMARY KEY CLUSTERED 
(
	[ST_CODE] ASC,
	[SELLER_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Client_Service_Type] ADD  CONSTRAINT [DF_T_Client_Service_Level_IsNotAllowed]  DEFAULT ((1)) FOR [IsAllowed]
GO
ALTER TABLE [dbo].[T_Client_Service_Type] ADD  CONSTRAINT [DF_T_Client_Service_Type_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
