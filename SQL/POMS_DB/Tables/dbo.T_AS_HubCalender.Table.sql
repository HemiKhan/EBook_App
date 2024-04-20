USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_AS_HubCalender]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_AS_HubCalender](
	[TimeStamp] [timestamp] NOT NULL,
	[HubCalenderID] [int] IDENTITY(1,1) NOT NULL,
	[HUB_CODE] [nvarchar](20) NOT NULL,
	[StarDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_AS_HubCalender] PRIMARY KEY CLUSTERED 
(
	[HubCalenderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_AS_HubCalender] ADD  CONSTRAINT [DF_T_AS_HubCalender_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_AS_HubCalender] ADD  CONSTRAINT [DF_T_AS_HubCalender_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
