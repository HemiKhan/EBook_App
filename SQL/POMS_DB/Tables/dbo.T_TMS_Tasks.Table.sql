USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_TMS_Tasks]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_Tasks](
	[TimeStamp] [timestamp] NOT NULL,
	[T_ID] [int] IDENTITY(1,1) NOT NULL,
	[TaskName] [nvarchar](250) NOT NULL,
	[Note] [nvarchar](max) NOT NULL,
	[Application_MTV_ID] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__83BB1FB2BE169C24] PRIMARY KEY CLUSTERED 
(
	[T_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_Tasks] ADD  CONSTRAINT [DF_T_Task_Management_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_Tasks] ADD  CONSTRAINT [DF_T_Task_Management_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
