USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Route_Schedule_Capacity_Default]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Route_Schedule_Capacity_Default](
	[TimeStamp] [timestamp] NOT NULL,
	[RSCD_ID] [int] IDENTITY(1,1) NOT NULL,
	[RL_ID] [int] NOT NULL,
	[DensityType_MTV_CODE] [nvarchar](20) NOT NULL,
	[Capacity] [int] NOT NULL,
	[IsIgnorePickup] [bit] NOT NULL,
	[Priority] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Route_Schedule_Capacity_Default] PRIMARY KEY CLUSTERED 
(
	[RSCD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity_Default] ADD  CONSTRAINT [DF_T_Route_Schedule_Capacity_Default_IsIgnorePickup]  DEFAULT ((1)) FOR [IsIgnorePickup]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity_Default] ADD  CONSTRAINT [DF_T_Route_Schedule_Capacity_Default_Priority]  DEFAULT ((1)) FOR [Priority]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity_Default] ADD  CONSTRAINT [DF_T_Route_Schedule_Capacity_Default_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity_Default] ADD  CONSTRAINT [DF_T_Route_Schedule_Capacity_Default_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity_Default]  WITH CHECK ADD  CONSTRAINT [FK_T_Route_Schedule_Capacity_Default_T_Route_List] FOREIGN KEY([RL_ID])
REFERENCES [dbo].[T_Route_List] ([RL_ID])
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity_Default] CHECK CONSTRAINT [FK_T_Route_Schedule_Capacity_Default_T_Route_List]
GO
