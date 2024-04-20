USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Audit_History]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Audit_History](
	[TimeStamp] [timestamp] NOT NULL,
	[OAH_ID] [int] IDENTITY(1,1) NOT NULL,
	[AC_ID] [int] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[AuditType_MTV_ID] [int] NOT NULL,
	[RefNo1] [nvarchar](50) NOT NULL,
	[RefNo2] [nvarchar](50) NOT NULL,
	[RefNo3] [nvarchar](50) NOT NULL,
	[OldValueHidden] [nvarchar](2000) NOT NULL,
	[NewValueHidden] [nvarchar](2000) NOT NULL,
	[OldValue] [nvarchar](2000) NOT NULL,
	[NewValue] [nvarchar](2000) NOT NULL,
	[Reason] [nvarchar](1000) NOT NULL,
	[IsAuto] [bit] NOT NULL,
	[Source_MTV_ID] [int] NOT NULL,
	[TriggerDebugInfo] [nvarchar](4000) NULL,
	[ChangedBy] [nvarchar](150) NOT NULL,
	[ChangedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_T_Sales_Order_Audit_History] PRIMARY KEY CLUSTERED 
(
	[OAH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Audit_History] ADD  CONSTRAINT [DF_T_Sales_Order_Audit_History_IsAuto]  DEFAULT ((0)) FOR [IsAuto]
GO
ALTER TABLE [dbo].[T_Order_Audit_History] ADD  CONSTRAINT [DF_T_Sales_Order_Audit_History_ChangedOn]  DEFAULT (getutcdate()) FOR [ChangedOn]
GO
ALTER TABLE [dbo].[T_Order_Audit_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Order_Audit_History_T_Audit_Column] FOREIGN KEY([AC_ID])
REFERENCES [dbo].[T_Audit_Column] ([AC_ID])
GO
ALTER TABLE [dbo].[T_Order_Audit_History] CHECK CONSTRAINT [FK_T_Order_Audit_History_T_Audit_Column]
GO
