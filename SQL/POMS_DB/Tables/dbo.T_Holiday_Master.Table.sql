USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Holiday_Master]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Holiday_Master](
	[TimeStamp] [timestamp] NOT NULL,
	[HM_ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[Month] [smallint] NOT NULL,
	[Day] [smallint] NOT NULL,
	[DayofMonth_MTV_CODE] [nvarchar](20) NOT NULL,
	[IsSaturdayInclude] [bit] NOT NULL,
	[IsSundayInclude] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Holiday_Master] PRIMARY KEY CLUSTERED 
(
	[HM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Holiday_Master] ADD  CONSTRAINT [DF_T_Holiday_Master_IsSaturdayInclude]  DEFAULT ((0)) FOR [IsSaturdayInclude]
GO
ALTER TABLE [dbo].[T_Holiday_Master] ADD  CONSTRAINT [DF_T_Holiday_Master_IsSundayInclude]  DEFAULT ((0)) FOR [IsSundayInclude]
GO
ALTER TABLE [dbo].[T_Holiday_Master] ADD  CONSTRAINT [DF_T_Holiday_Master_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Holiday_Master] ADD  CONSTRAINT [DF_T_Holiday_Master_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
