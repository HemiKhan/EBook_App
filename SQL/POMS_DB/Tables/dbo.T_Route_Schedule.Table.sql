USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Route_Schedule]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Route_Schedule](
	[TimeStamp] [timestamp] NOT NULL,
	[RS_ID] [int] IDENTITY(1,1) NOT NULL,
	[RL_ID] [int] NOT NULL,
	[TypeofMonth_MTV_CODE] [nvarchar](20) NOT NULL,
	[SubTypeofMonth_MTV_CODE] [nvarchar](20) NOT NULL,
	[SpecificDate] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Route_Schedule] PRIMARY KEY CLUSTERED 
(
	[RS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Route_Schedule] ADD  CONSTRAINT [DF_T_Route_Schedule_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Route_Schedule] ADD  CONSTRAINT [DF_T_Route_Schedule_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Route_Schedule]  WITH CHECK ADD  CONSTRAINT [FK_T_Route_Schedule_T_Route_List] FOREIGN KEY([RL_ID])
REFERENCES [dbo].[T_Route_List] ([RL_ID])
GO
ALTER TABLE [dbo].[T_Route_Schedule] CHECK CONSTRAINT [FK_T_Route_Schedule_T_Route_List]
GO
