USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TasksAttachments]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		  
CREATE PROC [dbo].[P_AddOrEdit_TasksAttachments]
@TA_ID int,
@OriginalFileName nvarchar(500),
@FileName nvarchar(100),
@FileExt nvarchar(100),
@Path nvarchar(1000),
@DocumentType_MTV_ID int,
@AttachmentType_MTV_ID int,
@REFID1 int,
@REFID2 int,
@REFID3 int,
@REFID4 int,
@Active BIT = 1,
@Username nvarchar(150),
@pReturn_Code bit output,
@pReturn_Text  nvarchar(1000)  output,
@pReturnTA_ID int output,
@IPAddress nvarchar(20) = ''

AS
BEGIN
	DECLARE  @OldFile nvarchar(max)
	DECLARE  @OldFileName nvarchar(40)
	Declare  @OldOriginalFileName nvarchar(500)
	Declare  @OldFileExt nvarchar(100)
	Declare  @OldPath nvarchar(1000)
	Declare  @OldDocumentType_MTV_ID int
	Declare  @OldAttachmentType_MTV_ID int
	Declare  @OldREFID1 int
	Declare  @OldREFID2 int
	Declare  @OldREFID3 int
	Declare  @OldREFID4 int
	Declare  @OldActive BIT
	set @pReturn_Code  = 1
	set @pReturn_Text  = ''
	set @pReturnTA_ID=0

	DECLARE @TempReturn_Code bit
	DECLARE @TempReturn_Text nvarchar(40)

	set @TempReturn_Code=1
	set @TempReturn_Text=''

IF @TA_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_TaskAttachments] WHERE TA_ID = @TA_ID)
	BEGIN
	    
		SELECT @OldActive = IsActive FROM [POMS_DB].[dbo].[T_TMS_TaskAttachments] WHERE TA_ID = @TA_ID
		
		UPDATE [POMS_DB].[dbo].[T_TMS_TaskAttachments] Set IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE TA_ID = @TA_ID
		
		--IF @OldFileName <> @FileName
		--BEGIN	
		--	exec P_Add_Audit_History 'FileName' ,'T_TMS_TaskAttachments', @TA_ID, 166144, '', '', '', @OldFileName, @FileName, @OldFileName, @FileName, '', 0, 167100, @UserName
		--END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_TaskAttachments', @TA_ID, 166144, '', '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @TempReturn_Text = 'Task Attachments Updated Successfully!'
		SET @TempReturn_Code = 1
	END
	ELSE
	BEGIN
		SET @TempReturn_Text = 'Task Attachments does not exist!'
		SET @TempReturn_Code = 0
	END
END

ELSE
BEGIN
	IF @FileName <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_TMS_TaskAttachments] (OriginalFileName,[FileName],FileExt,[Path],DocumentType_MTV_ID,AttachmentType_MTV_ID,REFID1,REFID2,REFID3,REFID4,IsActive ,AddedBy, AddedOn) 
		VALUES (@OriginalFileName,@FileName,@FileExt,@Path,@DocumentType_MTV_ID,@AttachmentType_MTV_ID,@REFID1,@REFID2,@REFID3,@REFID4,@Active, @Username, GETUTCDATE())
		SET @TempReturn_Text = 'Task Attachments Added Successfully!'
		SET @TempReturn_Code = 1
		set @pReturnTA_ID=SCOPE_IDENTITY();
		 
	END
	ELSE BEGIN
		SET @TempReturn_Text = 'Task Attachments Name Not Found!'
		SET @TempReturn_Code = 0
	END
END
set @pReturn_Text =@TempReturn_Text
set @pReturn_Code=@TempReturn_Code

--SELECT @pReturn_Text Return_Text, @pReturn_Code Return_Code

END
GO
