USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskManagementSystem]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --		EXEC [dbo].[P_Remove_TaskManagementSystem] 1,1,'HAMMAS.KHAN',''
CREATE PROC [dbo].[P_Remove_TaskManagementSystem]
@T_ID INT,
@TD_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

	--BEGIN TRY
	--	BEGIN TRAN;
		-- Parameter validation
		IF @T_ID > 0 OR @TD_ID > 0
		BEGIN		
			-- Check if Task exists
			IF EXISTS (SELECT 1 FROM [POMS_DB].dbo.[T_TMS_Tasks] WHERE T_ID = @T_ID)
			BEGIN
				-- Check if Task exists
				IF EXISTS (SELECT 1 FROM [POMS_DB].dbo.[T_TMS_Tasks] WHERE T_ID = @T_ID)
				BEGIN
					-- Delete TaskAttachments
					DELETE FROM [POMS_DB].[dbo].[T_TMS_TaskAttachments] WHERE AttachmentType_MTV_ID = 179100 AND REFID1 = @TD_ID;

					-- Delete TaskComments
					DELETE FROM [POMS_DB].[dbo].[T_TMS_TaskComments] WHERE TD_ID = @TD_ID;

					-- Delete TaskAssignedTo_Mapping
					DELETE FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] WHERE TD_ID = @TD_ID;
										
					-- Delete TaskDetail
					DELETE FROM [POMS_DB].[dbo].[T_TMS_TaskDetail] WHERE T_ID = @T_ID AND TD_ID = @TD_ID;
					
					-- Delete Task
					IF NOT EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_TaskDetail] WITH (NOLOCK) WHERE T_ID = @T_ID)
					BEGIN
						DELETE FROM [POMS_DB].[dbo].[T_TMS_Tasks] WHERE T_ID = @T_ID;
					END

					SET @Return_Text = 'Task Removed Successfully!';
					SET @Return_Code = 1;
				END
				ELSE BEGIN 
					SET @Return_Text = 'TD_ID Not Exists!'
					SET @Return_Code = 0
				END			
			END
			ELSE BEGIN 
				SET @Return_Text = 'T_ID Not Exists!'
				SET @Return_Code = 0
			END			
		END
		ELSE BEGIN 
			SET @Return_Text = 'Invalid Task Ids'
			SET @Return_Code = 0
		END	

	--COMMIT;

 --   END TRY
 --   BEGIN CATCH
 --       ROLLBACK;
 --       SET @Return_Text = ERROR_MESSAGE();
 --       SET @Return_Code = 0;
 --   END CATCH

    SELECT @Return_Code AS Return_Code, @Return_Text AS Return_Text;	
END
GO
