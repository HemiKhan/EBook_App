USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_IU]
	@Json nvarchar(max)
	,@pUsername nvarchar(150)
	,@pIP nvarchar(20)
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 167100
AS
BEGIN
	
	set @pUserName = upper(@pUserName)

	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Declare @USER_ID int
    Declare @USERNAME NVARCHAR(50)
	Declare @UserType_MTV_CODE NVARCHAR(20)
	Declare @PasswordHash NVARCHAR(250)
	Declare @PasswordSalt NVARCHAR(250)
	Declare @D_ID int
	Declare @ROLE_ID int
	Declare @IsGroupRoleID bit
	Declare @Designation nvarchar(150)
	Declare @FirstName nvarchar(50)
	Declare @MiddleName nvarchar(50)
	Declare @LastName nvarchar(50)
	Declare @Company nvarchar(250)
	Declare @Address nvarchar(250)
	Declare @Address2 nvarchar(250)
	Declare @City nvarchar(50)
	Declare @State nvarchar(5)
	Declare @ZipCode nvarchar(10)
	Declare @Country nvarchar(50)
	Declare @Email nvarchar(250)
	Declare @Mobile nvarchar(30)
	Declare @Phone nvarchar(40)
	Declare @PhoneExt nvarchar(20)
	Declare @SecurityQuestion_MTV_ID int
	Declare @EncryptedAnswer nvarchar(250)
	Declare @TIMEZONE_ID int
	Declare @IsApproved bit
	Declare @BlockType_MTV_ID int
	Declare @IsAPIUser bit
	Declare @IsActive bit
	Declare @UserApplicationJson nvarchar(max)

	Declare @TemppReturn_Code bit = 0
	Declare @TemppReturn_Text nvarchar(1000) = ''
	Declare @TemppExecution_Error nvarchar(1000) = ''
	Declare @TemppError_Text nvarchar(max) = ''

	Begin Try
		
		select @USER_ID = [USER_ID]
		,@USERNAME = USERNAME
		,@UserType_MTV_CODE = UserType_MTV_CODE
		,@PasswordHash = PasswordHash
		,@PasswordSalt = PasswordSalt
		,@D_ID = D_ID
		,@ROLE_ID = ROLE_ID
		,@IsGroupRoleID = IsGroupRoleID
		,@Designation = Designation
		,@FirstName = FirstName
		,@MiddleName = MiddleName
		,@LastName = LastName
		,@Company = Company
		,@Address = [Address]
		,@Address2 = Address2
		,@City = City
		,@State = [State]
		,@ZipCode = ZipCode
		,@Country = Country
		,@Email = Email
		,@Mobile = Mobile
		,@Phone = Phone
		,@PhoneExt = PhoneExt
		,@SecurityQuestion_MTV_ID = SecurityQuestion_MTV_ID
		,@EncryptedAnswer = EncryptedAnswer
		,@TIMEZONE_ID = TIMEZONE_ID
		,@IsApproved = IsApproved
		,@BlockType_MTV_ID = BlockType_MTV_ID
		,@IsAPIUser = IsAPIUser
		,@IsActive = IsActive
		,@UserApplicationJson = UserApplicationJson
		from [POMS_DB].[dbo].[F_Get_T_UserDetials_JsonTable] (@Json)
		
		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if (@USER_ID = 0)
		begin
			
			exec [POMS_DB].[dbo].[P_Generate_UserID] @Ret_UserID = @USER_ID out

			insert into [POMS_DB].[dbo].[T_Users] ([USER_ID] ,USERNAME ,UserType_MTV_CODE ,PasswordHash ,PasswordSalt ,D_ID ,Designation ,FirstName ,MiddleName ,LastName ,Company ,[Address] ,Address2 ,City ,[State] ,ZipCode ,Country ,Email 
				,Mobile ,Phone ,PhoneExt ,SecurityQuestion_MTV_ID ,EncryptedAnswer ,TIMEZONE_ID ,IsApproved ,BlockType_MTV_ID ,IsAPIUser ,AddedBy)
			values (@USER_ID ,@USERNAME ,@UserType_MTV_CODE ,@PasswordHash ,@PasswordSalt ,@D_ID ,@Designation ,@FirstName ,@MiddleName ,@LastName ,@Company ,@Address ,@Address2 ,@City ,@State ,@ZipCode ,@Country ,@Email 
				,@Mobile ,@Phone ,@PhoneExt ,@SecurityQuestion_MTV_ID ,@EncryptedAnswer ,@TIMEZONE_ID ,@IsApproved ,@BlockType_MTV_ID ,@IsAPIUser ,@pUsername)

			set @pReturn_Code = 1
			set @pReturn_Text = 'Inserted'

		end
		else if exists(select * from [POMS_DB].[dbo].[T_Users] u where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME)
		begin
			drop table if exists #JsonOldEditUserTable 
			select u.[USER_ID]
			,u.USERNAME 
			,u.UserType_MTV_CODE
			,UserType_MTV_CODE_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (u.UserType_MTV_CODE)
			,u.PasswordHash
			,u.PasswordSalt
			,u.D_ID
			,D_ID_Name=[POMS_DB].[dbo].[F_Get_DepartmentName_From_D_ID] (u.D_ID)
			,u.Designation
			,u.FirstName
			,u.MiddleName
			,u.LastName
			,u.Company
			,u.[Address]
			,u.Address2
			,u.City
			,u.[State]
			,u.ZipCode
			,u.Country
			,u.Email
			,u.Mobile
			,u.Phone
			,u.PhoneExt
			,u.SecurityQuestion_MTV_ID
			,SecurityQuestion_MTV_ID_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (u.SecurityQuestion_MTV_ID)
			,u.EncryptedAnswer
			,u.TIMEZONE_ID
			,TIMEZONE_ID_Name=[POMS_DB].[dbo].[F_Get_TimeZoneName_From_TimeZoneID] (u.TIMEZONE_ID)
			,u.IsApproved
			,IsApproved_Name=(case u.IsApproved when 1 then 'Yes' else 'No' end)
			,u.BlockType_MTV_ID
			,BlockType_MTV_ID_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (u.BlockType_MTV_ID)
			,u.IsAPIUser
			,IsAPIUser_Name=(case u.IsAPIUser when 1 then 'Yes' else 'No' end)
			,u.IsActive
			,IsActive_Name=(case u.IsActive when 1 then 'Yes' else 'No' end)
			into #JsonOldEditUserTable   
			from [POMS_DB].[dbo].[T_Users] u with (nolock)
			where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME

			Update u 
			set u.UserType_MTV_CODE = @UserType_MTV_CODE
			,u.PasswordHash = @PasswordHash
			,u.PasswordSalt = @PasswordSalt
			,u.D_ID = @D_ID
			,u.Designation = @Designation
			,u.FirstName = @FirstName
			,u.MiddleName = @MiddleName
			,u.LastName = @LastName
			,u.Company = @Company
			,u.[Address] = @Address
			,u.Address2 = @Address2
			,u.City = @City
			,u.[State] = @State
			,u.ZipCode = @ZipCode
			,u.Country = @Country
			,u.Email = @Email
			,u.Mobile = @Mobile
			,u.Phone = @Phone
			,u.PhoneExt = @PhoneExt
			,u.SecurityQuestion_MTV_ID = @SecurityQuestion_MTV_ID
			,u.EncryptedAnswer = @EncryptedAnswer
			,u.TIMEZONE_ID = @TIMEZONE_ID
			,u.IsApproved = @IsApproved
			,u.BlockType_MTV_ID = @BlockType_MTV_ID
			,u.IsAPIUser = @IsAPIUser
			,u.IsActive = @IsActive
			,u.ModifiedBy = @pUsername
			,u.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Users] u where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME

			drop table if exists #JsonNewEditUserTable 
			select [USER_ID]=@USER_ID
			,USERNAME=@USERNAME
			,UserType_MTV_CODE=isnull(@UserType_MTV_CODE,'')
			,UserType_MTV_CODE_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (u.UserType_MTV_CODE)
			,PasswordHash=isnull(@PasswordHash,'')
			,PasswordSalt=isnull(@PasswordSalt,'')
			,D_ID=isnull(@D_ID,0)
			,D_ID_Name=[POMS_DB].[dbo].[F_Get_DepartmentName_From_D_ID] (u.D_ID)
			,Designation=isnull(@Designation,'')
			,FirstName=isnull(@FirstName,'')
			,MiddleName=isnull(@MiddleName,'')
			,LastName=isnull(@LastName,'')
			,Company=isnull(@Company,'')
			,[Address]=isnull(@Address,'')
			,Address2=isnull(@Address2,'')
			,City=isnull(@City,'')
			,[State]=isnull(@State,'')
			,ZipCode=isnull(@ZipCode,'')
			,Country=isnull(@Country,'')
			,Email=isnull(@Email,'')
			,Mobile=isnull(@Mobile,'')
			,Phone=isnull(@Phone,'')
			,PhoneExt=isnull(@PhoneExt,'')
			,SecurityQuestion_MTV_ID=isnull(@SecurityQuestion_MTV_ID,0)
			,SecurityQuestion_MTV_ID_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@SecurityQuestion_MTV_ID)
			,EncryptedAnswer=isnull(@EncryptedAnswer,'')
			,TIMEZONE_ID=isnull(@TIMEZONE_ID,0)
			,TIMEZONE_ID_Name=[POMS_DB].[dbo].[F_Get_TimeZoneName_From_TimeZoneID] (@TIMEZONE_ID)
			,IsApproved=isnull(@IsApproved,0)
			,IsApproved_Name=(case @IsApproved when 1 then 'Yes' else 'No' end)
			,BlockType_MTV_ID=isnull(@BlockType_MTV_ID,0)
			,BlockType_MTV_ID_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@BlockType_MTV_ID)
			,IsAPIUser=isnull(@IsAPIUser,0)
			,IsAPIUser_Name=(case @IsAPIUser when 1 then 'Yes' else 'No' end)
			,IsActive=isnull(@IsActive,0)
			,IsActive_Name=(case @IsActive when 1 then 'Yes' else 'No' end)
			into #JsonNewEditUserTable   
			from [POMS_DB].[dbo].[T_Users] u with (nolock)
			where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME

			exec [POMS_DB].[dbo].[P_User_IU_ChangeLog] @plogIsEdit = 1 ,@plogUserName = @USERNAME ,@plogSource_MTV_ID = @pSource_MTV_ID

			set @pReturn_Code = 1
			set @pReturn_Text = 'Updated'
		end
		else 
		begin
			set @pReturn_Code = 1
			set @pReturn_Text = 'Invalid UserID and UserName'
		end

		if (@pReturn_Code = 1 and @ROLE_ID <> 0)
		begin
			select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

			exec [POMS_DB].[dbo].[P_User_Role_Mapping_IU] @USERNAME ,@pIP ,@ROLE_ID ,@IsGroupRoleID ,@pUsername ,@pReturn_Code = @TemppReturn_Code out ,@pReturn_Text = @TemppReturn_Text out 
				,@pExecution_Error = @TemppExecution_Error out ,@pError_Text = @TemppError_Text out ,@pIsBeginTransaction = @pIsBeginTransaction ,@pSource_MTV_ID = @pSource_MTV_ID

			select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text
		end

		if (@pReturn_Code = 1 and isnull(@UserApplicationJson,'') <> '')
		begin
			select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

			exec [POMS_DB].[dbo].[P_User_Application_Mapping_IU] @UserApplicationJson ,@pUsername ,@pIP ,@pReturn_Code = @TemppReturn_Code out ,@pReturn_Text = @TemppReturn_Text out 
				,@pExecution_Error = @TemppExecution_Error out ,@pError_Text = @TemppError_Text out ,@pIsBeginTransaction = @pIsBeginTransaction ,@pSource_MTV_ID = @pSource_MTV_ID

			select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text
		end

		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_User_IU: ' + ERROR_MESSAGE()
	End catch


END
GO
