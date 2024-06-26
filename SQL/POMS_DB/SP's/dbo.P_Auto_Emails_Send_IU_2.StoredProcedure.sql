USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Auto_Emails_Send_IU_2]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[P_Auto_Emails_Send_IU_2]
	-- Add the parameters for the stored procedure here
	@AE_ID int
	,@Email_Subject nvarchar(1000)
	,@Email_Body nvarchar(max)
	,@Is_Error bit
	,@Is_HTML bit
	,@AEP_ID int
	,@Is_Attachment bit
	,@Priority int
	,@Email_To nvarchar(max)
	,@Email_BCC nvarchar(max)
	,@Email_CC nvarchar(max)
	,@Is_Email_Ready bit = 1
	
	
AS
BEGIN
	
	exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID ,@Email_Subject ,@Email_Body ,@Is_Error ,@Is_HTML ,@AEP_ID ,@Is_Attachment ,@Priority ,@Email_To ,@Email_BCC ,@Email_CC ,@Is_Email_Ready

END
GO
