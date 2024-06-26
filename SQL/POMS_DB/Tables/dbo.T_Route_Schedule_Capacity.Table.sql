USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Route_Schedule_Capacity]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Route_Schedule_Capacity](
	[TimeStamp] [timestamp] NOT NULL,
	[RSC_ID] [int] IDENTITY(1,1) NOT NULL,
	[RS_ID] [int] NOT NULL,
	[DensityType_MTV_CODE] [nvarchar](20) NOT NULL,
	[Capacity] [int] NOT NULL,
	[IsIgnorePickup] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Route_Schedule_Capacity] PRIMARY KEY CLUSTERED 
(
	[RSC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity] ADD  CONSTRAINT [DF_T_Route_Schedule_Capacity_IsIgnorePickup]  DEFAULT ((1)) FOR [IsIgnorePickup]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity] ADD  CONSTRAINT [DF_T_Route_Schedule_Capacity_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity] ADD  CONSTRAINT [DF_T_Route_Schedule_Capacity_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity]  WITH CHECK ADD  CONSTRAINT [FK_T_Route_Schedule_Capacity_T_Route_Schedule] FOREIGN KEY([RS_ID])
REFERENCES [dbo].[T_Route_Schedule] ([RS_ID])
GO
ALTER TABLE [dbo].[T_Route_Schedule_Capacity] CHECK CONSTRAINT [FK_T_Route_Schedule_Capacity_T_Route_Schedule]
GO
