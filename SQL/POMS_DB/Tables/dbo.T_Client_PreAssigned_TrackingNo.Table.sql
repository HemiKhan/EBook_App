USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Client_PreAssigned_TrackingNo]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Client_PreAssigned_TrackingNo](
	[TimeStamp] [timestamp] NOT NULL,
	[CPATN_ID] [int] IDENTITY(1,1) NOT NULL,
	[Request_ID] [nvarchar](36) NOT NULL,
	[PreAssignedTrackingNo] [nvarchar](20) NOT NULL,
	[SELLER_KEY] [nvarchar](36) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsUsed] [bit] NOT NULL,
	[RequestedBy] [nvarchar](150) NOT NULL,
	[RequestedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Client_PreAssigned_TrackingNo] PRIMARY KEY CLUSTERED 
(
	[CPATN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Client_PreAssigned_TrackingNo] ADD  CONSTRAINT [DF_T_Client_PreAssigned_TrackingNo_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Client_PreAssigned_TrackingNo] ADD  CONSTRAINT [DF_T_Client_PreAssigned_TrackingNo_IsUsed]  DEFAULT ((0)) FOR [IsUsed]
GO
ALTER TABLE [dbo].[T_Client_PreAssigned_TrackingNo] ADD  CONSTRAINT [DF_T_Client_PreAssigned_TrackingNo_RequestedOn]  DEFAULT (getutcdate()) FOR [RequestedOn]
GO
