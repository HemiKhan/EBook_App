USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Route_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Route_List](
	[TimeStamp] [timestamp] NOT NULL,
	[RL_ID] [int] NOT NULL,
	[Start_HUB_CODE] [nvarchar](20) NOT NULL,
	[End_HUB_CODE] [nvarchar](20) NOT NULL,
	[Route_MTV_ID] [int] NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[TransitDays] [int] NOT NULL,
	[ScheduleType_MTV_ID] [int] NOT NULL,
	[AllowAPIScheduling] [bit] NOT NULL,
	[DaysToAppointment] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Route_List] PRIMARY KEY CLUSTERED 
(
	[RL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Route_List] ADD  CONSTRAINT [DF_T_Route_List_TransitDays]  DEFAULT ((0)) FOR [TransitDays]
GO
ALTER TABLE [dbo].[T_Route_List] ADD  CONSTRAINT [DF_T_Route_List_AllowAPIScheduling]  DEFAULT ((0)) FOR [AllowAPIScheduling]
GO
