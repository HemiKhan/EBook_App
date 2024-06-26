USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Clients_Users_Mapping]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Clients_Users_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[LCUM_ID] [int] IDENTITY(1,1) NOT NULL,
	[LC_ID] [int] NOT NULL,
	[USERNAME] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Clients_Users_Mapping] PRIMARY KEY CLUSTERED 
(
	[LCUM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Clients_Users_Mapping] ADD  CONSTRAINT [DF_T_Clients_Users_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Clients_Users_Mapping] ADD  CONSTRAINT [DF_T_Clients_Users_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Clients_Users_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Clients_Users_Mapping_T_Clients] FOREIGN KEY([LC_ID])
REFERENCES [dbo].[T_LogiwaClient] ([LC_ID])
GO
ALTER TABLE [dbo].[T_Clients_Users_Mapping] CHECK CONSTRAINT [FK_T_Clients_Users_Mapping_T_Clients]
GO
