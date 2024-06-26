USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_AssignedToList]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 
Create PROC [dbo].[P_AddOrEdit_AssignedToList]
@TAL_ID int,
@AssignToType_MTV_CODE nvarchar(20),
@AssignedTo nvarchar(150),
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	 
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TAL_ID >0
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_AssignedTo_List] WITH (NOLOCK) WHERE TAL_ID = @TAL_ID)
	BEGIN
	    
     Declare	@OldAssignToType_MTV_CODE nvarchar(20)
     Declare	@OldAssignedTo nvarchar(150)
     Declare	@OldIsActive BIT = 1
		
		SELECT @OldAssignToType_MTV_CODE=AssignToType_MTV_CODE , @OldAssignedTo=AssignedTo   FROM [POMS_DB].[dbo].[T_TMS_AssignedTo_List] WITH (NOLOCK) WHERE TAL_ID = @TAL_ID
		
		UPDATE [POMS_DB].[dbo].[T_TMS_AssignedTo_List] SET AssignToType_MTV_CODE=@AssignToType_MTV_CODE, AssignedTo=@AssignedTo ,  IsActive = @IsActive ,ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE TAL_ID = @TAL_ID

		IF @OldAssignToType_MTV_CODE <> @AssignToType_MTV_CODE
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'AssignToType_MTV_CODE' ,'T_TMS_AssignedTo_List', @TAL_ID, 166153, @TAL_ID, '', '', @OldAssignToType_MTV_CODE, @AssignToType_MTV_CODE, @OldAssignToType_MTV_CODE, @AssignToType_MTV_CODE, '', 0, 167100, @UserName
		END

		 IF @OldAssignedTo <> @AssignedTo
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'OldAssignedTo' ,'T_TMS_AssignedTo_List', @TAL_ID, 166153, @TAL_ID, '', '', @OldAssignedTo, @AssignedTo, @OldAssignedTo, @AssignedTo, '', 0, 167100, @UserName
		END


		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_TMS_AssignedTo_List', @TAL_ID, 166153, '', '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'AssignedTo List Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'AssignedTo List does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @AssignToType_MTV_CODE <> '' 
	BEGIN
		 
		INSERT INTO [POMS_DB].[dbo].T_TMS_AssignedTo_List (AssignToType_MTV_CODE,  AssignedTo, IsActive, AddedBy, AddedOn) 
		VALUES ( @AssignToType_MTV_CODE, @AssignedTo, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'AssignedTo List Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'AssignedTo List  Assign To Type Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
