USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Users_Token]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Users_Token](
	[TimeStamp] [timestamp] NOT NULL,
	[Application_MTV_ID] [int] NOT NULL,
	[Username] [nvarchar](150) NOT NULL,
	[TOKEN] [nvarchar](250) NULL,
	[TOKEN_CREATED_ON] [datetime] NULL,
	[TOKEN_EXPIRY] [datetime] NULL,
	[TOKEN_REVOKED_ON] [datetime] NULL,
	[OTP] [nvarchar](50) NULL,
	[OTP_EXPIRY] [datetime] NULL,
	[OTP_STATUS] [int] NULL,
 CONSTRAINT [PK_T_Users_Token] PRIMARY KEY CLUSTERED 
(
	[Application_MTV_ID] ASC,
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
