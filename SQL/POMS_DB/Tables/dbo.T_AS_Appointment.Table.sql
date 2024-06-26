USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_AS_Appointment]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_AS_Appointment](
	[TimeStamp] [timestamp] NOT NULL,
	[AptID] [int] IDENTITY(1,1) NOT NULL,
	[Company] [nvarchar](250) NOT NULL,
	[HUB_CODE] [nvarchar](20) NOT NULL,
	[USERNAME] [nvarchar](50) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[TrailerNo] [nvarchar](50) NULL,
	[Driver] [nvarchar](250) NULL,
	[Qty] [int] NOT NULL,
	[Cubes] [decimal](5, 2) NULL,
	[TotalWeight] [decimal](5, 2) NULL,
	[Status] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_AS_Appointment] PRIMARY KEY CLUSTERED 
(
	[AptID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_AS_Appointment] ADD  CONSTRAINT [DF_T_AS_Appointment_Status]  DEFAULT ((100)) FOR [Status]
GO
ALTER TABLE [dbo].[T_AS_Appointment] ADD  CONSTRAINT [DF_T_AS_Appointment_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_AS_Appointment] ADD  CONSTRAINT [DF_T_AS_Appointment_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
