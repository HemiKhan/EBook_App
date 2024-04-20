USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Special_Services_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Special_Services_List](
	[TimeStamp] [timestamp] NOT NULL,
	[SSL_CODE] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[IsAvailableForPickup] [bit] NOT NULL,
	[IsAvailableForDelivery] [bit] NOT NULL,
	[IsReqMints] [bit] NOT NULL,
	[IsFloorsRequired] [bit] NOT NULL,
	[IsDaysRequired] [bit] NOT NULL,
	[IsEstAmountRequired] [bit] NOT NULL,
	[IsFromDateRequired] [bit] NOT NULL,
	[IsToDateRequired] [bit] NOT NULL,
	[IsManRequired] [bit] NOT NULL,
	[IsDefaultMintsZero] [bit] NOT NULL,
	[IsDefaultFloorZero] [bit] NOT NULL,
	[IsDefaultDaysZero] [bit] NOT NULL,
	[IsDefaultEstAmountZero] [bit] NOT NULL,
	[IsDefaultFromDateNULL] [bit] NOT NULL,
	[IsDefaultToDateNULL] [bit] NOT NULL,
	[IsDefaultManZero] [bit] NOT NULL,
	[IsAllowed] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Special_Services_List] PRIMARY KEY CLUSTERED 
(
	[SSL_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Special_Services_List] ADD  CONSTRAINT [DF_T_Special_Services_List_IsAllowed]  DEFAULT ((1)) FOR [IsAllowed]
GO
ALTER TABLE [dbo].[T_Special_Services_List] ADD  CONSTRAINT [DF_T_Special_Services_List_Is_Active]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Special_Services_List] ADD  CONSTRAINT [DF_T_Special_Services_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
