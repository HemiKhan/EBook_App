USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Create_User]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @Ret_Return_Code bit = 0 Declare @Ret_Return_Text nvarchar(1000) = '' Declare @Ret_Execution_Error nvarchar(1000) = '' Declare @Ret_Error_Text nvarchar(max) = ''  exec [POMS_DB].[dbo].[P_Create_User] '', 'ABDULLAH.ARSHAD', '', @Ret_Return_Code out, @Ret_Return_Text out, @Ret_Execution_Error out, @Ret_Error_Text out, 167100 select @Ret_Return_Code , @Ret_Return_Text , @Ret_Execution_Error , @Ret_Error_Text 
-- =============================================
CREATE PROCEDURE [dbo].[P_Create_User]
	@Json nvarchar(max)
	,@Username nvarchar(150)
	,@IP nvarchar(20)
	,@Return_Code bit output
	,@Return_Text nvarchar(1000) output
	,@Execution_Error nvarchar(1000) output
	,@Error_Text nvarchar(max) output
	,@Source_MTV_ID int = 167100
AS
BEGIN
	
--	set @Json = '[{
--  "UserDetails": {
--    "USER_ID": 0,
--    "UserType_MTV_CODE": "CLIENT-USER",
--    "USERNAME": "IHTISHAMTETS",
--    "PasswordHash": "wYcG7JVpbgNCadCKqWpTyLQ/dfE72XqGqBql1wGxWFsqrfzN/rC1Pg==",
--    "PasswordSalt": "20OHHVQFyBn+sb1PL4tu2bVtDxM=",
--    "D_ID": 1,
--	  "R_ID": 2,
--	  "IsGroupRoleID": true,
--    "Designation": "developer",
--    "FirstName": "ihatism",
--    "MiddleName": " ulhaq",
--    "LastName": "ulhaq",
--    "Company": "MPL",
--    "Address": " PWD Islamabad",
--    "Address2": "PWD Islamabad",
--    "Country": "Pakistan",
--    "City": "Islamabad",
--    "State": "punjab",
--    "ZipCode": "123234",
--    "Email": "ihtsham@gomwd.com",
--    "Mobile": "32534545",
--    "Phone": "532454354",
--    "PhoneExt": "343245435",
--    "SecurityQuestion_MTV_ID": 150100,
--    "EncryptedAnswer": "92B14FD4C1F4AE8D13F95B9BAF4EBF4D",
--    "BlockType_MTV_ID": 149101,
--    "TIMEZONE_ID": 13,
--    "IsApproved": true,
--    "IsAPIUser": true,
--    "IsActive": true,
--	  "ApplicationAccess": [
--		{
--			"UAA_ID": 0,
--			"USERNAME": "IHTISHAMTETS",
--			"Application_MTV_ID": 148100,
--			"NAV_USERNAME": "",
--			"IsActive": true
--		}
--	]
--  },
--  "UserSeller": [
--    {
--      "UserToSeller": {
--        "UTSM_ID": 0,
--        "UserName": "IHTISHAMTETS",
--		    "SELLER_KEY": "0A8B8263-C9DE-4AFD-BCC6-8FAFD12C9E08",
--        "IsViewOrder": true,
--        "IsCreateOrder": true,
--        "IsGetQuote": true,
--        "IsFinancial": true,
--        "IsAdmin": true,
--        "IsBlankSubSellerAllowed": true,
--        "IsAllSubSellerAllowed": true,
--        "IsBlankPartnerAllowed": true,
--        "IsAllPartnerAllowed": true,
--        "IsBlankTariffAllowed": true,
--        "IsAllTariffAllowed": true,
--        "IsActive": true
--      },
--      "BillTo": [ 
--        {
--          "USTSBM_ID": 0,
--          "UserName": "IHTISHAMTETS",
--          "SBM_ID": 2025,
--          "IsViewOrder": true,
--          "IsCreateOrder": true,
--          "IsGetQuote": true,
--          "IsFinancial": true,
--          "IsActive": true
--        }
--      ],
--      "PartnerTo": [
--        {
--          "USTSPM_ID": 0,
--          "UserName": "IHTISHAMTETS",
--          "SPM_ID": 1,
--          "IsViewOrder": true,
--          "IsCreateOrder": true,
--          "IsGetQuote": true,
--          "IsFinancial": true,
--          "IsActive": true
--        }
--      ],
--      "SubSellerTo": [
--        {
--          "USTSSM_ID": 0,
--          "UserName": "IHTISHAMTETS",
--          "SSM_ID": 1,
--          "IsViewOrder": true,
--          "IsCreateOrder": true,
--          "IsGetQuote": true,
--          "IsFinancial": true,
--          "IsActive": true
--        }
--      ],
--      "Tariff": [
--        {
--          "USTSTM_ID": 0,
--          "UserName": "IHTISHAMTETS",
--          "STM_ID": 1,
--		  "IsViewOrder": true,
--          "IsCreateOrder": true,
--          "IsGetQuote": true,
--          "IsFinancial": true,
--          "IsActive": true
--        }
--      ]
--    }
--  ]
--}]'

	Declare @UserDetails nvarchar(max) = ''
	Declare @UserSeller nvarchar(max) = ''
	Declare @UserDetailsTable table (ID int identity(1,1), UserDetails nvarchar(max) ,UserSeller nvarchar(max))

	insert into @UserDetailsTable (UserDetails, UserSeller)
	select UserDetails, UserSeller from [POMS_DB].[dbo].[F_Get_Create_User_JsonTable] (@Json)
	
	Declare @TemppReturn_Code bit = 1
	Declare @TemppReturn_Text nvarchar(1000) = ''
	Declare @TemppExecution_Error nvarchar(1000) = ''
	Declare @TemppError_Text nvarchar(max) = ''

	set @Return_Code = 0
	set @Return_Text = ''
	set @Execution_Error = ''
	set @Error_Text = ''

	Declare @TryCount int = 0
	Declare @MaxCount int = 0
	select @MaxCount = max(ID) from @UserDetailsTable
	while @TryCount < @MaxCount
	begin
		begin try
			set @Return_Code = 0
			Begin Transaction

			set @TryCount = @TryCount + 1

			select @UserDetails = UserDetails, @UserSeller = UserSeller from @UserDetailsTable where ID = @TryCount
			
			if isnull(@UserDetails,'') <> '' and @TemppReturn_Code = 1
			begin
				select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''
			
				exec [POMS_DB].[dbo].[P_User_IU] @Json = @UserDetails, @pUsername = @Username ,@pIP = @IP ,@pReturn_Code = @TemppReturn_Code out, @pReturn_Text = @TemppReturn_Text out, @pExecution_Error = @TemppExecution_Error out 
				,@pError_Text = @TemppError_Text out ,@pIsBeginTransaction = 0, @pSource_MTV_ID = @Source_MTV_ID

				select @Return_Code = @TemppReturn_Code
				, @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TemppError_Text

			end

			if isnull(@UserSeller,'') <> '' and @TemppReturn_Code = 1
			begin
				select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''
			
				exec [POMS_DB].[dbo].[P_User_Seller_Mapping_IU] @Json = @UserSeller ,@pAddedby = @Username ,@pIP = @IP ,@pReturn_Code = @TemppReturn_Code out,@pReturn_Text = @TemppReturn_Text out,@pExecution_Error = @TemppExecution_Error out
				,@pError_Text = @TemppError_Text out ,@pIsBeginTransaction = 0, @pSource_MTV_ID = @Source_MTV_ID

				select @Return_Code = @TemppReturn_Code
				, @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TemppError_Text
			end

			if @@TRANCOUNT > 0 and @Return_Code = 1
			begin
				COMMIT; 
			end
			else if @@TRANCOUNT > 0 and @Return_Code = 0
			begin
				ROLLBACK; 
			end

			if (@Return_Code = 1)
			begin
				set @TryCount = @TryCount + 1
			end
			else
			begin
				set @TryCount = @MaxCount
			end

		end try
		begin catch
			set @Return_Code = 0
			if @@TRANCOUNT > 0
			begin
				ROLLBACK; 
			end
			Set @Error_Text = 'P_Create_User: ' + ERROR_MESSAGE()
		end catch

	end


END

GO
