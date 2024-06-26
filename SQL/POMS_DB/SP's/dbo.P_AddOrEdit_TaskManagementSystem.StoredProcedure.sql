USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskManagementSystem]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      <Author Name>
-- Create date: <Create Date>
-- Description: <Description>
-- =============================================


CREATE PROCEDURE [dbo].[P_AddOrEdit_TaskManagementSystem]
    @Json nvarchar(max),
    @Username nvarchar(150),
    @IPAddress nvarchar(20)=''
AS
BEGIN
IF @Json = ''
    BEGIN
   --     set @Return_Code='No Data in Json'
		 --set  @Return_Code=0 
		 return
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
   --       set @Return_Code='No Data in Json'
		 --set  @Return_Code=0
		 return
        END
    END
    DECLARE @Return_Code bit = 0
    DECLARE @Return_Text nvarchar(1000) = ''
    DECLARE @Error_Text nvarchar(1000) = ''
	Declare @ReturnT_ID int
    Declare @ReturnTD_ID int
    Declare @ReturnTA_ID int
	Declare @ReturnTable Table (T_ID int, TD_ID int, TA_ID int,[FileName] nvarchar(40), Return_Code bit, Return_Text Nvarchar(1000))
    --Declare @spTA_ID int
    BEGIN TRY
        BEGIN TRANSACTION
		
		SET @Return_Code = 0
		SET @ReturnT_ID =0
        
         
        -- Variables for Task Returns
        DECLARE @TaskReturn_Code bit
        DECLARE @TaskReturn_Text nvarchar(1000)  
		
        -- Variables for Task Details Returns
        DECLARE @TaskDetailsReturn_Code bit
        DECLARE @TaskDetailsReturn_Text nvarchar(1000)  

        -- Variables for Task and Attachment Counts
        DECLARE @TaskDetailsCount int = 0
        DECLARE @TaskAttachmentsCount int = 0
        DECLARE @TaskDetailsMaxCount int = 0
        DECLARE @TaskAttachmentsMaxCount int = 0

        -- Variables for Task Details
        DECLARE @TD_ID int
        DECLARE @TaskDetailsID int
        DECLARE @Task_Item nvarchar(1000)
        DECLARE @Task_Item_Detail nvarchar(max)
        DECLARE @Application_URL nvarchar(max)
        DECLARE @Task_Start_Date Date
        DECLARE @Task_End_Date Date
        DECLARE @Priority_MTV_Code int
        DECLARE @Status_MTV_Code int
        DECLARE @BUILDCODE nvarchar(50) = ''
        DECLARE @TaskCategory_MTV_ID int
		DECLARE @Review_Date Date
		DECLARE @ETA_Date Date
		DECLARE @LeadAssignTo nvarchar(150)
        DECLARE @IsPrivate bit=0
        DECLARE @TaskDetailActive bit=1
        DECLARE @TD_IDSpReturn int=0
        DECLARE @AttachmentsJson nvarchar(max)

        -- Variables for Attachment Details
        DECLARE @TA_ID int
        DECLARE @OriginalFileName nvarchar(500)
        --DECLARE @File nvarchar(max)
        DECLARE @FileName nvarchar(40)
        DECLARE @FileExt nvarchar(20)
		Declare @Path Nvarchar(1000)
		Declare @DocumentType_MTV_ID int
		Declare @AttachmentType_MTV_ID int
		Declare @REFID1 int
		Declare @REFID2	int
		Declare @REFID3	int
		Declare @REFID4	int
        DECLARE @AttachmentsIsActive bit
        DECLARE @IsActive bit = 1

        -- Variables for Task
        DECLARE @T_ID int
        DECLARE @Application_MTV_ID int
        DECLARE @TaskName nvarchar(500)
        DECLARE @Note nvarchar(Max)
		Declare @TaskActive bit
        DECLARE @TaskItemsJson nvarchar(max)
        DECLARE @TIDSpReturn int=0;

		Declare @AttachmentsReturnCode bit
		Declare @AttachmentsReturnText Nvarchar(1000)

		set @TIDSpReturn=0;
		set @TD_IDSpReturn=0;

        -- Table Variables
        DECLARE @TaskDeatilsTabel table (
            tempTaskID int identity(1, 1),
            TD_ID int,
            T_IDReturn int,
            Task_Item nvarchar(400),
            Task_Item_Detail nvarchar(max),
            Application_URL nvarchar(max),
            Task_Start_Date DateTime,
            Task_End_Date DateTime,
            Priority_MTV_Code int,
            Status_MTV_Code int,
			BUILDCODE nvarchar(50),
            TaskCategory_MTV_ID int,
			Review_Date Date,
			ETA_Date Date,
			LeadAssignTo nvarchar(150),
            IsPrivate bit,
			TaskDetailActive bit,
            AttachmentsJson nvarchar(max)
        )

        DECLARE @AttachmentsTabel table (
            tempAttachID int identity(1, 1),
            TA_ID int,
            FileType_ID int,
			OriginalFileName nvarchar(500),
			[FileName] nvarchar(100),
			FileExt nvarchar(100),
            --[File] nvarchar(max),
			[Path] nvarchar(1000),
			DocumentType_MTV_ID int,
			AttachmentType_MTV_ID int,
			REFID1 int ,
			REFID2 int,
			REFID3 int,
			REFID4 int,
			AttachmentsIsActive bit
        )

        -- Output Tables
        DECLARE @OutPutTasksTable table(Return_Text nvarchar(1000), Return_Code bit, T_IDReturn int)
        DECLARE @OutPutTasksDetailsTable table(Return_Text nvarchar(1000), Return_Code bit, TD_IDReturn int)

        -- Get Task details from JSON input
        SELECT @T_ID = T_ID,
               @Application_MTV_ID = Application_MTV_ID,
               @TaskName = TaskName,
               @Note = Note,
			   @TaskActive=TaskActive,
               @TaskItemsJson = TaskItemsJson
        FROM [POMS_DB].[dbo].[F_Get_T_TMS_Tasks_JsonTable](@Json)

		  
		  
        -- Insert Task Details into Temp Table
        INSERT INTO @TaskDeatilsTabel (TD_ID,Task_Item,Task_Item_Detail,Application_URL,Task_Start_Date,Task_End_Date,Priority_MTV_Code,Status_MTV_Code ,BUILDCODE,  TaskCategory_MTV_ID , Review_Date, ETA_Date ,LeadAssignTo , IsPrivate , TaskDetailActive,AttachmentsJson)
        SELECT TD_ID,Task_Item,Task_Item_Detail,Application_URL,Task_Start_Date,Task_End_Date,Priority_MTV_Code,Status_MTV_Code ,BUILDCODE,  TaskCategory_MTV_ID , Review_Date, ETA_Date ,LeadAssignTo , IsPrivate , TaskDetailActive,AttachmentsJson
        FROM [POMS_DB].[dbo].[F_Get_TMS_TaskDetail_JsonTable](@TaskItemsJson)

		

        -- Get the maximum Task Details Count
        SELECT @TaskDetailsMaxCount = MAX(tempTaskID) FROM @TaskDeatilsTabel
        -- Execute Task Addition or Edition Procedure and get result
        DELETE FROM @OutPutTasksTable;
        INSERT INTO @OutPutTasksTable(Return_Text, Return_Code, T_IDReturn)
        EXEC [POMS_DB].[dbo].[P_AddOrEdit_Tasks] @T_ID, @Application_MTV_ID, @TaskName, @Note, @TaskActive, @Username
        
		SELECT @TIDSpReturn = T_IDReturn, @TaskReturn_Code = Return_Code, @TaskReturn_Text = Return_Text FROM @OutPutTasksTable
        SET @Return_Text = @TaskReturn_Text
        SET @Return_Code = @TaskReturn_Code
		
		if @TIDSpReturn=0
		begin
		Set @ReturnT_ID=@T_ID
		end
		else
		begin
		Set @ReturnT_ID=@TIDSpReturn
		end
		
        -- If Task Addition or Edition Successful
		 
        IF @TaskReturn_Code = 1
        BEGIN 
            WHILE @TaskDetailsCount < @TaskDetailsMaxCount
            BEGIN
                SET @TaskDetailsCount = @TaskDetailsCount + 1;
				SET @AttachmentsJson='';
				 SET @ReturnTD_ID=0
         
                -- Get Task Details for iteration
                SELECT @TD_ID=TD_ID,@TaskDetailsID=@TIDSpReturn, @Task_Item=Task_Item,@Task_Item_Detail=Task_Item_Detail,@Application_URL=Application_URL,@Task_Start_Date=Task_Start_Date,@Task_End_Date=Task_End_Date,@Priority_MTV_Code=Priority_MTV_Code,@Status_MTV_Code=Status_MTV_Code ,@BUILDCODE=BUILDCODE,  @TaskCategory_MTV_ID=TaskCategory_MTV_ID , @Review_Date=Review_Date, @ETA_Date=ETA_Date ,@LeadAssignTo = LeadAssignTo, @IsPrivate=IsPrivate , @TaskDetailActive=TaskDetailActive, @AttachmentsJson=AttachmentsJson
                FROM @TaskDeatilsTabel where tempTaskID=@TaskDetailsCount
               
				 
                 --Set Task ID based on existing or new Task
				--set @IsPrivate=0
                IF @TaskDetailsID = 0
                BEGIN
                    SET @T_ID = @TIDSpReturn;
                END
                ELSE
                BEGIN
                    SET @T_ID = @TaskDetailsID;
                END
				  
                -- Execute Task Details Addition or Edition Procedure
                DELETE FROM @OutPutTasksDetailsTable;
                INSERT INTO @OutPutTasksDetailsTable(Return_Text, Return_Code, TD_IDReturn)  
                EXEC P_AddOrEdit_TaskDetail @TD_ID, @T_ID, @Task_Item, @Task_Item_Detail, @Application_URL, @Task_Start_Date, @Task_End_Date, @Priority_MTV_Code, @Status_MTV_Code, @BUILDCODE, @TaskCategory_MTV_ID,@Review_Date, @ETA_Date, @LeadAssignTo ,@IsPrivate, @TaskDetailActive, @Username, @IPAddress

                -- Get Task Details result
                SELECT @TD_IDSpReturn = TD_IDReturn, @TaskDetailsReturn_Code = Return_Code, @TaskDetailsReturn_Text = Return_Text FROM @OutPutTasksDetailsTable;

                -- If Task Details Addition or Edition Successful
				 --Set @ReturnTD_ID=@ReturnTD_ID+','+cast(@TD_IDSpReturn AS nvarchar(100))
				  
				if @TD_ID=0
				 Begin
				  SET @ReturnTD_ID=@TD_IDSpReturn
				 
				  End
				  Else
				  Begin
				    SET @ReturnTD_ID=@TD_ID
				  End
         
                IF @TaskDetailsReturn_Code = 1
                BEGIN 
                    -- Get Attachment Count for iteration
				delete from @AttachmentsTabel
                insert into @AttachmentsTabel ( TA_ID  ,OriginalFileName  ,[FileName]  ,FileExt  ,[Path]  ,DocumentType_MTV_ID  ,AttachmentType_MTV_ID  ,REFID1  ,REFID2  ,REFID3  ,REFID4  ,AttachmentsIsActive )
                select TA_ID  ,OriginalFileName  ,[FileName]  ,FileExt  ,[Path]  ,DocumentType_MTV_ID  ,AttachmentType_MTV_ID  ,REFID1  ,REFID2  ,REFID3  ,REFID4  ,AttachmentsIsActive from [POMS_DB].[dbo].[F_Get_TMS_TaskAttachments_JsonTable](@AttachmentsJson)
						 
                   SELECT @TaskAttachmentsMaxCount = MAX(tempAttachID) FROM @AttachmentsTabel

                    -- Iterate through Attachments
                    WHILE @TaskAttachmentsCount < @TaskAttachmentsMaxCount
                    BEGIN
                        SET @TaskAttachmentsCount = @TaskAttachmentsCount + 1
						SET @ReturnTA_ID =0
                        -- Get Attachment Details for iteration
                        SELECT @TA_ID = TA_ID, @OriginalFileName=OriginalFileName,@FileName = [FileName], @FileExt = FileExt,@Path=[Path],@DocumentType_MTV_ID=DocumentType_MTV_ID,@AttachmentType_MTV_ID=AttachmentType_MTV_ID,@REFID1=REFID1,@REFID2=REFID2,@REFID3=REFID3,@REFID1=REFID1,@REFID2=REFID2,@REFID4=REFID4, @AttachmentsIsActive=AttachmentsIsActive FROM @AttachmentsTabel WHERE tempAttachID = @TaskAttachmentsCount
						  --REFID1 is treated is TD_ID
						  IF @REFID2 = 0
								BEGIN
									SET @REFID2 = @TD_IDSpReturn;
									 
								END
								  
                            EXEC P_AddOrEdit_TasksAttachments @TA_ID,@OriginalFileName, @FileName, @FileExt, @Path, @DocumentType_MTV_ID,@AttachmentType_MTV_ID,@REFID1,@REFID2,@REFID3,@REFID4,@AttachmentsIsActive, @Username, @pReturn_Code=@AttachmentsReturnCode out,@pReturn_Text=@AttachmentsReturnText Out,@pReturnTA_ID= @ReturnTA_ID out
                            --SET @ReturnTA_ID = @ReturnTA_ID + ',' + CAST(@spTA_ID AS nvarchar(100));
							insert into @ReturnTable(T_ID,TD_ID,TA_ID,[FileName])
							select @ReturnT_ID,@ReturnTD_ID,@ReturnTA_ID,@FileName
							
							if(@AttachmentsReturnCode=1)
							begin
							 
								SET @Return_Text = CONCAT(@Return_Text, ',', @AttachmentsReturnText);
								SET @Return_Code = 1
                            end
							ELSE
							BEGIN
				
								-- If Task Attachment addition or edit failed
								SET @Return_Text = @Return_Text + ',' +@AttachmentsReturnText;
								SET @Return_Code = 0
								 
							END
                         
                    END

                    -- Set overall return text and code
                    SET @Return_Text = @Return_Text + ',' + @TaskDetailsReturn_Text;
                    SET @Return_Code = 1
                END
                ELSE
                BEGIN
				
                    -- If Task Details addition or edit failed
                    SET @Return_Text = @Return_Text + ',' + 'T_TMS_TaskDetail_'+@TaskDetailsReturn_Text;
                    SET @Return_Code = 0
					 
                END
            END
        END
        ELSE
        BEGIN
            -- If Task addition or edition failed
			
            SET @Return_Text = CONCAT(@Return_Text, ',', @TaskReturn_Text);
            SET @Return_Code = 0
			ROLLBACK
			
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
        SET @Return_Text = 'P_AddOrEdit_TaskManagementSystem: ' + ERROR_MESSAGE()
    END CATCH

    -- Return final result
	--@Error_Text AS Error_Text 
	if @Return_Code=0
	Begin 
	SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code, @T_ID As T_ID,@TD_ID as TD_ID ,@TA_ID as TA_ID ,@FileName As  [FileName]
	End
    else
	begin
	 IF EXISTS (SELECT 1 FROM @ReturnTable)
BEGIN
    update @ReturnTable set Return_Text=@Return_Text,Return_Code=1 
	SELECT Return_Text, Return_Code, T_ID,TD_ID,TA_ID,[FileName] from @ReturnTable 
End
Else
Begin
SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code
End
	
	end
END
GO
