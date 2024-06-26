USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Process_Files]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Process_Files](
	[TimeStamp] [timestamp] NOT NULL,
	[OPF] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [nvarchar](36) NOT NULL,
	[OriginalFileName] [nvarchar](1000) NOT NULL,
	[FileExt] [nvarchar](10) NOT NULL,
	[Path_] [nvarchar](1000) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Process_Files] PRIMARY KEY CLUSTERED 
(
	[OPF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Process_Files] ADD  CONSTRAINT [DF_T_Order_Process_Files_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Process_Files] ADD  CONSTRAINT [DF_T_Order_Process_Files_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
