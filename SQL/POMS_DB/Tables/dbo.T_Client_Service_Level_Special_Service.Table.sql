USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Client_Service_Level_Special_Service]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Client_Service_Level_Special_Service](
	[TimeStamp] [timestamp] NOT NULL,
	[SELLER_CODE] [nvarchar](20) NOT NULL,
	[SLSS_ID] [int] NOT NULL,
	[IsOpted] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Client_Service_Level_Special_Service] PRIMARY KEY CLUSTERED 
(
	[SELLER_CODE] ASC,
	[SLSS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Client_Service_Level_Special_Service] ADD  CONSTRAINT [DF_T_Client_Service_Level_Special_Service_IsOpted]  DEFAULT ((0)) FOR [IsOpted]
GO
ALTER TABLE [dbo].[T_Client_Service_Level_Special_Service] ADD  CONSTRAINT [DF_T_Client_Service_Level_Special_Service_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Client_Service_Level_Special_Service] ADD  CONSTRAINT [DF_T_Client_Service_Level_Special_Service_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
