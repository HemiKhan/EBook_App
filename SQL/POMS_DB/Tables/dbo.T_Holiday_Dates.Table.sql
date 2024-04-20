USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Holiday_Dates]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Holiday_Dates](
	[TimeStamp] [timestamp] NOT NULL,
	[HD_ID] [int] IDENTITY(1,1) NOT NULL,
	[HM_ID] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Holiday_Dates] PRIMARY KEY CLUSTERED 
(
	[HD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Holiday_Dates] ADD  CONSTRAINT [DF_T_Holiday_Dates_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Holiday_Dates] ADD  CONSTRAINT [DF_T_Holiday_Dates_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Holiday_Dates]  WITH CHECK ADD  CONSTRAINT [FK_T_Holiday_Dates_T_Holiday_Master] FOREIGN KEY([HM_ID])
REFERENCES [dbo].[T_Holiday_Master] ([HM_ID])
GO
ALTER TABLE [dbo].[T_Holiday_Dates] CHECK CONSTRAINT [FK_T_Holiday_Dates_T_Holiday_Master]
GO
