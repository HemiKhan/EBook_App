USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_TMS_TaskAttachments]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_TaskAttachments](
	[TimeStamp] [timestamp] NOT NULL,
	[TA_ID] [int] IDENTITY(1,1) NOT NULL,
	[OriginalFileName] [nvarchar](250) NOT NULL,
	[FileName] [nvarchar](50) NOT NULL,
	[FileExt] [nvarchar](10) NOT NULL,
	[Path] [nvarchar](500) NOT NULL,
	[DocumentType_MTV_ID] [int] NOT NULL,
	[AttachmentType_MTV_ID] [int] NOT NULL,
	[REFID1] [int] NOT NULL,
	[REFID2] [int] NULL,
	[REFID3] [int] NULL,
	[REFID4] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__2F5D5550E47FC396] PRIMARY KEY CLUSTERED 
(
	[TA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_TMS_TaskAttachments] ADD  CONSTRAINT [DF_T_TMS_TaskAttachments_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskAttachments] ADD  CONSTRAINT [DF_T_TMS_TaskAttachments_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
