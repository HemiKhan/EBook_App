USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Update_TasksAttachmentsPath]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec P_Update_TasksAttachmentsPath 1,'testforupdate',35,''

CREATE PROC [dbo].[P_Update_TasksAttachmentsPath]
@TA_ID int,
@Path nvarchar(1000),
@TD_ID int,
@Username nvarchar(150)='',
@IPAddress nvarchar(20) = ''
AS
BEGIN
 Declare @Return_Code bit
Declare  @Return_Text  nvarchar(1000)
  BEGIN TRY
        BEGIN TRANSACTION
  IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_TaskAttachments] WHERE TA_ID = @TA_ID)
	BEGIN
		UPDATE [POMS_DB].[dbo].[T_TMS_TaskAttachments] SET [Path] = @Path WHERE TA_ID = @TA_ID
		SET @Return_Code = 1
		SET @Return_Text = 'Attachment path Updated'
	END
	ELSE
	BEGIN
		SET @Return_Code = 0
		SET @Return_Text = 'Attachment Not Found'
	END
 
 -- Finalize transaction
        IF @@TRANCOUNT > 0 AND @Return_Code = 1
        BEGIN
            COMMIT; 
        END
        ELSE IF @@TRANCOUNT > 0 AND @Return_Code = 0
        BEGIN
            ROLLBACK; 
        END
    END TRY
    BEGIN CATCH
        -- Error handling
        SET @Return_Code = 0
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK; 
        END
        SET @Return_Text = 'P_Update_TasksAttachmentsPath: ' + ERROR_MESSAGE()
    END CATCH

 select @Return_Text As Return_Text  ,@Return_Code  As Return_Code
End


 
GO
