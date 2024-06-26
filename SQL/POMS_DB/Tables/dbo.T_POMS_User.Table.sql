USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_POMS_User]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_POMS_User](
	[TimeStamp] [timestamp] NOT NULL,
	[Username] [nvarchar](50) NOT NULL,
	[TOKEN] [nvarchar](100) NULL,
	[TOKEN_CREATED_ON] [datetime] NULL,
	[TOKEN_EXPIRY] [datetime] NULL,
	[TOKEN_REVOKED_ON] [datetime] NULL,
	[OTP] [nvarchar](50) NULL,
	[OTP_EXPIRY] [datetime] NULL,
	[OTP_STATUS] [int] NULL,
 CONSTRAINT [PK_T_POMS_User] PRIMARY KEY CLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
