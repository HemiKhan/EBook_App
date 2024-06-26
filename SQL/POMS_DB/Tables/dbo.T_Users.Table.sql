USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Users]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Users](
	[TimeStamp] [timestamp] NOT NULL,
	[USER_ID] [nvarchar](150) NOT NULL,
	[USERNAME] [nvarchar](50) NOT NULL,
	[UserType_MTV_CODE] [nvarchar](20) NOT NULL,
	[PasswordHash] [nvarchar](250) NOT NULL,
	[PasswordSalt] [nvarchar](250) NOT NULL,
	[D_ID] [int] NOT NULL,
	[Designation] [nvarchar](150) NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Company] [nvarchar](250) NULL,
	[Address] [nvarchar](250) NULL,
	[Address2] [nvarchar](250) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](5) NULL,
	[ZipCode] [nvarchar](10) NULL,
	[Country] [nvarchar](50) NULL,
	[Email] [nvarchar](250) NULL,
	[Mobile] [nvarchar](30) NULL,
	[Phone] [nvarchar](20) NULL,
	[PhoneExt] [nvarchar](10) NULL,
	[SecurityQuestion_MTV_ID] [int] NOT NULL,
	[EncryptedAnswer] [nvarchar](250) NOT NULL,
	[TIMEZONE_ID] [int] NOT NULL,
	[IsApproved] [bit] NOT NULL,
	[BlockType_MTV_ID] [int] NOT NULL,
	[TempBlockTillDateTime] [datetime] NULL,
	[PasswordExpiryDateTime] [datetime] NOT NULL,
	[IsAPIUser] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Users] PRIMARY KEY CLUSTERED 
(
	[USER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_TIMEZONE_ID]  DEFAULT ((13)) FOR [TIMEZONE_ID]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsApproved]  DEFAULT ((1)) FOR [IsApproved]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_PasswordExpiry]  DEFAULT (getutcdate()) FOR [PasswordExpiryDateTime]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsAPIUser]  DEFAULT ((0)) FOR [IsAPIUser]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
