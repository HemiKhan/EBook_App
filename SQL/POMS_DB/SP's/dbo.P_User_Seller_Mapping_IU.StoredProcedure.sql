USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_Seller_Mapping_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_Seller_Mapping_IU]
	@Json nvarchar(max)
	,@pAddedby nvarchar(150)
	,@pIP nvarchar(20)
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 167100
AS
BEGIN
	
	set @pAddedby = upper(@pAddedby)

	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Declare @UTSM_ID int
	Declare @UserName nvarchar(150)
	Declare @SELLER_ID int
	Declare @IsViewOrder bit
	Declare @IsCreateOrder bit
	Declare @IsGetQuote bit
	Declare @IsFinancial bit
	Declare @IsAdmin bit
	Declare @IsBlankSubSellerAllowed bit
	Declare @IsAllSubSellerAllowed bit
	Declare @IsBlankPartnerAllowed bit
	Declare @IsAllPartnerAllowed bit
	Declare @IsBlankTariffAllowed bit
	Declare @IsAllTariffAllowed bit
	Declare @IsActive bit
	
	Declare @SellerJson nvarchar(max) = ''
	Declare @SellerBillToJson nvarchar(max) = ''
	Declare @SellerSubSellerJson nvarchar(max) = ''
	Declare @SellerPartnerJson nvarchar(max) = ''
	Declare @SellerTariffJson nvarchar(max) = ''

	Declare @TemppReturn_Code bit = 1
	Declare @TemppReturn_Text nvarchar(1000) = ''
	Declare @TemppExecution_Error nvarchar(1000) = ''
	Declare @TemppError_Text nvarchar(max) = ''

	Begin Try
		
		select @SellerJson = UserToSellerJson
		,@SellerBillToJson = BillToJson
		,@SellerSubSellerJson = SubSellerToJson
		,@SellerPartnerJson = PartnerToJson
		,@SellerTariffJson = TariffJson
		from [POMS_DB].[dbo].[F_Get_UserSellerList_JsonTable] (@Json)

		if (isnull(@SellerJson,'') <> '')
		begin

			select @UTSM_ID = UTSM_ID
			,@UserName = UserName
			,@SELLER_ID = SELLER_ID
			,@IsViewOrder = IsViewOrder
			,@IsCreateOrder = IsCreateOrder
			,@IsGetQuote = IsGetQuote
			,@IsFinancial = IsFinancial
			,@IsAdmin = IsAdmin
			,@IsBlankSubSellerAllowed = IsBlankSubSellerAllowed
			,@IsAllSubSellerAllowed = IsAllSubSellerAllowed
			,@IsBlankPartnerAllowed = IsBlankPartnerAllowed
			,@IsAllPartnerAllowed = IsAllPartnerAllowed
			,@IsBlankTariffAllowed = IsBlankTariffAllowed
			,@IsAllTariffAllowed = IsAllTariffAllowed
			,@IsActive = IsActive
			from [POMS_DB].[dbo].[F_Get_T_UserToSeller_JsonTable] (@SellerJson)

			if @pIsBeginTransaction = 1
			begin
				Begin Transaction
			end

			if (@UTSM_ID = 0)
			begin
			
				insert into [POMS_DB].[dbo].[T_User_To_Seller_Mapping] (UserName, SELLER_ID, IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial ,IsAdmin ,IsBlankSubSellerAllowed ,IsAllSubSellerAllowed ,IsBlankPartnerAllowed 
				,IsAllPartnerAllowed ,IsBlankTariffAllowed ,IsAllTariffAllowed ,IsActive ,AddedBy)
				values (@UserName, @SELLER_ID, @IsViewOrder ,@IsCreateOrder ,@IsGetQuote ,@IsFinancial ,@IsAdmin ,@IsBlankSubSellerAllowed ,@IsAllSubSellerAllowed ,@IsBlankPartnerAllowed 
				,@IsAllPartnerAllowed ,@IsBlankTariffAllowed ,@IsAllTariffAllowed ,@IsActive ,@pAddedby)

				set @pReturn_Code = 1
				set @pReturn_Text = 'Inserted'

			end
			else if exists(select * from [POMS_DB].[dbo].[T_User_To_Seller_Mapping] usm with (nolock) where usm.UTSM_ID = @UTSM_ID and usm.UserName = @UserName)
			begin
				drop table if exists #JsonOldEditUserSellerMappingTable 
				select usm.UTSM_ID
				,usm.UserName 
				,SELLER_ID = SELLER_ID
				,SELLER_NAME = (select top 1 sl.Company from [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) where sl.SELLER_ID = usm.SELLER_ID)
				,IsViewOrder = IsViewOrder
				,IsViewOrderName = (Case IsViewOrder when 1 then 'Yes' else 'No' end)
				,IsCreateOrder = IsCreateOrder
				,IsCreateOrderName = (Case IsCreateOrder when 1 then 'Yes' else 'No' end)
				,IsGetQuote = IsGetQuote
				,IsGetQuoteName = (Case IsGetQuote when 1 then 'Yes' else 'No' end)
				,IsFinancial = IsFinancial
				,IsFinancialName = (Case IsFinancial when 1 then 'Yes' else 'No' end)
				,IsAdmin = IsAdmin
				,IsAdminName = (Case IsAdmin when 1 then 'Yes' else 'No' end)
				,IsBlankSubSellerAllowed = IsBlankSubSellerAllowed
				,IsBlankSubSellerAllowedName = (Case IsBlankSubSellerAllowed when 1 then 'Yes' else 'No' end)
				,IsAllSubSellerAllowed = IsAllSubSellerAllowed
				,IsAllSubSellerAllowedName = (Case IsAllSubSellerAllowed when 1 then 'Yes' else 'No' end)
				,IsBlankPartnerAllowed = IsBlankPartnerAllowed
				,IsBlankPartnerAllowedName = (Case IsBlankPartnerAllowed when 1 then 'Yes' else 'No' end)
				,IsAllPartnerAllowed = IsAllPartnerAllowed
				,IsAllPartnerAllowedName = (Case IsAllPartnerAllowed when 1 then 'Yes' else 'No' end)
				,IsBlankTariffAllowed = IsBlankTariffAllowed
				,IsBlankTariffAllowedName = (Case IsBlankTariffAllowed when 1 then 'Yes' else 'No' end)
				,IsAllTariffAllowed = IsAllTariffAllowed
				,IsAllTariffAllowedName = (Case IsAllTariffAllowed when 1 then 'Yes' else 'No' end)
				,IsActive = IsActive
				,IsActiveName = (Case IsActive when 1 then 'Yes' else 'No' end)
				into #JsonOldEditUserSellerMappingTable  
				from [POMS_DB].[dbo].[T_User_To_Seller_Mapping] usm with (nolock)
				where usm.UTSM_ID = @UTSM_ID and usm.UserName = @UserName
			
				Update usm
					set usm.SELLER_ID = @SELLER_ID
					,usm.IsViewOrder = @IsViewOrder
					,usm.IsCreateOrder = @IsCreateOrder
					,usm.IsGetQuote = @IsGetQuote
					,usm.IsFinancial = @IsFinancial
					,usm.IsAdmin = @IsAdmin
					,usm.IsBlankSubSellerAllowed = @IsBlankSubSellerAllowed
					,usm.IsAllSubSellerAllowed = @IsAllSubSellerAllowed
					,usm.IsBlankPartnerAllowed = @IsBlankPartnerAllowed
					,usm.IsAllPartnerAllowed = @IsAllPartnerAllowed
					,usm.IsBlankTariffAllowed = @IsBlankTariffAllowed
					,usm.IsAllTariffAllowed = @IsAllTariffAllowed
					,usm.IsActive = @IsActive
					,usm.ModifiedBy = @pAddedby
					,usm.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_User_To_Seller_Mapping] usm where usm.UTSM_ID = @UTSM_ID and usm.UserName = @UserName

				drop table if exists #JsonNewEditUserSellerMappingTable 
				select UTSM_ID = @UTSM_ID
				,UserName = @UserName 
				,SELLER_ID = @SELLER_ID
				,SELLER_NAME = (select top 1 sl.Company from [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) where sl.SELLER_ID = @SELLER_ID)
				,IsViewOrder = @IsViewOrder
				,IsViewOrderName = (Case @IsViewOrder when 1 then 'Yes' else 'No' end)
				,IsCreateOrder = @IsCreateOrder
				,IsCreateOrderName = (Case @IsCreateOrder when 1 then 'Yes' else 'No' end)
				,IsGetQuote = @IsGetQuote
				,IsGetQuoteName = (Case @IsGetQuote when 1 then 'Yes' else 'No' end)
				,IsFinancial = @IsFinancial
				,IsFinancialName = (Case @IsFinancial when 1 then 'Yes' else 'No' end)
				,IsAdmin = @IsAdmin
				,IsAdminName = (Case @IsAdmin when 1 then 'Yes' else 'No' end)
				,IsBlankSubSellerAllowed = @IsBlankSubSellerAllowed
				,IsBlankSubSellerAllowedName = (Case @IsBlankSubSellerAllowed when 1 then 'Yes' else 'No' end)
				,IsAllSubSellerAllowed = @IsAllSubSellerAllowed
				,IsAllSubSellerAllowedName = (Case @IsAllSubSellerAllowed when 1 then 'Yes' else 'No' end)
				,IsBlankPartnerAllowed = @IsBlankPartnerAllowed
				,IsBlankPartnerAllowedName = (Case @IsBlankPartnerAllowed when 1 then 'Yes' else 'No' end)
				,IsAllPartnerAllowed = @IsAllPartnerAllowed
				,IsAllPartnerAllowedName = (Case @IsAllPartnerAllowed when 1 then 'Yes' else 'No' end)
				,IsBlankTariffAllowed = @IsBlankTariffAllowed
				,IsBlankTariffAllowedName = (Case @IsBlankTariffAllowed when 1 then 'Yes' else 'No' end)
				,IsAllTariffAllowed = @IsAllTariffAllowed
				,IsAllTariffAllowedName = (Case @IsAllTariffAllowed when 1 then 'Yes' else 'No' end)
				,IsActive = @IsActive
				,IsActiveName = (Case @IsActive when 1 then 'Yes' else 'No' end)
				into #JsonNewEditUserSellerMappingTable  

				exec [POMS_DB].[dbo].[P_User_Seller_Mapping_IU_ChangeLog] @plogIsEdit = 1, @plogUserName = @pAddedby, @plogSource_MTV_ID = @pSource_MTV_ID

				set @pReturn_Code = 1
				set @pReturn_Text = 'Updated'
			end
			else 
			begin
				set @pReturn_Code = 1
				set @pReturn_Text = 'Invalid UTSM_ID & UserName'
			end
		end
		
		if ((@pReturn_Code = 0 and isnull(@SellerJson,'') = '') or (@pReturn_Code = 1 and isnull(@SellerJson,'') <> ''))
		begin
			set @pReturn_Code = 1
			if isnull(@SellerBillToJson,'') <> '' and @TemppReturn_Code = 1
			begin
				select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

				exec [POMS_DB].[dbo].[P_User_Seller_To_BillTo_Mapping_IU] @ppJson = @SellerBillToJson ,@ppAddedby = @pAddedby ,@ppIP = @pIP ,@ppReturn_Code = @TemppReturn_Code out ,@ppReturn_Text = @TemppReturn_Text out 
				,@ppExecution_Error = @TemppExecution_Error out ,@ppError_Text = @TemppError_Text out ,@ppIsBeginTransaction = @pIsBeginTransaction ,@ppSource_MTV_ID = @pSource_MTV_ID

				select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text

			end

			if isnull(@SellerSubSellerJson,'') <> '' and @TemppReturn_Code = 1
			begin
				select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

				exec [POMS_DB].[dbo].[P_User_Seller_To_SubSeller_Mapping_IU] @ppJson = @SellerSubSellerJson ,@ppAddedby = @pAddedby ,@ppIP = @pIP ,@ppReturn_Code = @TemppReturn_Code out ,@ppReturn_Text = @TemppReturn_Text out 
				,@ppExecution_Error = @TemppExecution_Error out ,@ppError_Text = @TemppError_Text out ,@ppIsBeginTransaction = @pIsBeginTransaction ,@ppSource_MTV_ID = @pSource_MTV_ID

				select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text
			end
			
			if isnull(@SellerPartnerJson,'') <> '' and @TemppReturn_Code = 1
			begin
				select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

				exec [POMS_DB].[dbo].[P_User_Seller_To_Partner_Mapping_IU] @ppJson = @SellerPartnerJson ,@ppAddedby = @pAddedby ,@ppIP = @pIP ,@ppReturn_Code = @TemppReturn_Code out ,@ppReturn_Text = @TemppReturn_Text out 
				,@ppExecution_Error = @TemppExecution_Error out ,@ppError_Text = @TemppError_Text out ,@ppIsBeginTransaction = @pIsBeginTransaction ,@ppSource_MTV_ID = @pSource_MTV_ID

				select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text
			end

			if isnull(@SellerTariffJson,'') <> '' and @TemppReturn_Code = 1
			begin
				select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

				exec [POMS_DB].[dbo].[P_User_Seller_To_Tariff_Mapping_IU] @ppJson = @SellerTariffJson ,@ppAddedby = @pAddedby ,@ppIP = @pIP ,@ppReturn_Code = @TemppReturn_Code out ,@ppReturn_Text = @TemppReturn_Text out 
				,@ppExecution_Error = @TemppExecution_Error out ,@ppError_Text = @TemppError_Text out ,@ppIsBeginTransaction = @pIsBeginTransaction ,@ppSource_MTV_ID = @pSource_MTV_ID

				select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text
			end
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
		set @pReturn_Code = 0
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_User_Seller_Mapping_IU: ' + ERROR_MESSAGE()
	End catch


END
GO
