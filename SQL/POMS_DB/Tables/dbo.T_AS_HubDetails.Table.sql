USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_AS_HubDetails]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_AS_HubDetails](
	[TimeStamp] [timestamp] NOT NULL,
	[HubDetailsID] [int] IDENTITY(1,1) NOT NULL,
	[HUB_CODE] [nvarchar](20) NOT NULL,
	[SlotInMinutes] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_AS_HubDetails] PRIMARY KEY CLUSTERED 
(
	[HubDetailsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_AS_HubDetails] ADD  CONSTRAINT [DF_T_AS_HubDetails_SlotInMinutes]  DEFAULT ((60)) FOR [SlotInMinutes]
GO
ALTER TABLE [dbo].[T_AS_HubDetails] ADD  CONSTRAINT [DF_T_AS_HubDetails_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_AS_HubDetails] ADD  CONSTRAINT [DF_T_AS_HubDetails_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
