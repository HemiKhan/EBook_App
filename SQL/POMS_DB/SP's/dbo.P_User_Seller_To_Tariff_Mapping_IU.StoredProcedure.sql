USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_Seller_To_Tariff_Mapping_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_Seller_To_Tariff_Mapping_IU]
	@ppJson nvarchar(max)
	,@ppAddedby nvarchar(150)
	,@ppIP nvarchar(20)
	,@ppReturn_Code bit output
	,@ppReturn_Text nvarchar(1000) output
	,@ppExecution_Error nvarchar(1000) output
	,@ppError_Text nvarchar(max) output
	,@ppIsBeginTransaction bit = 1
	,@ppSource_MTV_ID int = 167100
AS
BEGIN
	
	set @ppAddedby = upper(@ppAddedby)

	set @ppReturn_Code = 0
	set @ppReturn_Text = ''
	set @ppExecution_Error = ''
	set @ppError_Text = ''

	Declare @USTSTM_ID int
	Declare @UserName nvarchar(150)
	Declare @STM_ID int
	Declare @IsViewOrder bit
	Declare @IsCreateOrder bit
	Declare @IsGetQuote bit
	Declare @IsFinancial bit
	Declare @IsActive bit

	Begin Try
		
		Declare @UserSellerToTariffTable table 
		(ID int identity(1,1)
		,USTSTM_ID int
		,UserName nvarchar(150)
		,STM_ID int
		,IsViewOrder bit
		,IsCreateOrder bit
		,IsGetQuote bit
		,IsFinancial bit
		,IsActive bit)

		insert into @UserSellerToTariffTable (USTSTM_ID ,UserName ,STM_ID ,IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial ,IsActive)
		select USTSTM_ID ,UserName ,STM_ID ,IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial ,IsActive from [POMS_DB].[dbo].[F_Get_T_UserSellerToTariff_JsonTable] (@ppJson)
		
		Declare @TryCount int = 1
		Declare @MaxCount int = 0
		select @MaxCount = max(ID) from @UserSellerToTariffTable
		while @TryCount <= @MaxCount
		begin
			set @ppReturn_Code = 0
			set @ppReturn_Text = ''

			select @USTSTM_ID = USTSTM_ID
			,@UserName = UserName 
			,@STM_ID = STM_ID
			,@IsViewOrder = IsViewOrder
			,@IsCreateOrder = IsCreateOrder
			,@IsGetQuote = IsGetQuote
			,@IsFinancial = IsFinancial
			,@IsActive = IsActive
			from @UserSellerToTariffTable where ID = @TryCount

			if @ppIsBeginTransaction = 1
			begin
				Begin Transaction
			end

			if @USTSTM_ID = 0
			begin
				insert into [POMS_DB].[dbo].[T_User_Seller_To_Tariff_Mapping] (UserName, STM_ID, IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial ,IsActive ,AddedBy)
				values (@UserName, @STM_ID, @IsViewOrder ,@IsCreateOrder ,@IsGetQuote ,@IsFinancial ,@IsActive ,@ppAddedby)

				set @ppReturn_Code = 1
				set @ppReturn_Text = 'Inserted'
			end
			else if exists(select * from [POMS_DB].[dbo].[T_User_Seller_To_Tariff_Mapping] ustm with (nolock) where ustm.USTSTM_ID = @USTSTM_ID and ustm.UserName = @UserName)
			begin
				drop table if exists #JsonOldEditUserSellerTariffMappingTable 
				select ustm.USTSTM_ID
				,ustm.UserName 
				,IsViewOrder = IsViewOrder
				,IsViewOrderName = (Case IsViewOrder when 1 then 'Yes' else 'No' end)
				,IsCreateOrder = IsCreateOrder
				,IsCreateOrderName = (Case IsCreateOrder when 1 then 'Yes' else 'No' end)
				,IsGetQuote = IsGetQuote
				,IsGetQuoteName = (Case IsGetQuote when 1 then 'Yes' else 'No' end)
				,IsFinancial = IsFinancial
				,IsFinancialName = (Case IsFinancial when 1 then 'Yes' else 'No' end)
				,IsActive = IsActive
				,IsActiveName = (Case IsActive when 1 then 'Yes' else 'No' end)
				into #JsonOldEditUserSellerTariffMappingTable  
				from [POMS_DB].[dbo].[T_User_Seller_To_Tariff_Mapping] ustm with (nolock)
				where ustm.USTSTM_ID = @USTSTM_ID and ustm.UserName = @UserName

				Update ustm
					set ustm.STM_ID = @STM_ID
					,ustm.IsViewOrder = @IsViewOrder
					,ustm.IsCreateOrder = @IsCreateOrder
					,ustm.IsGetQuote = @IsGetQuote
					,ustm.IsFinancial = @IsFinancial
					,ustm.IsActive = @IsActive
					,ustm.ModifiedBy = @ppAddedby
					,ustm.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_User_Seller_To_Tariff_Mapping] ustm where ustm.USTSTM_ID = @USTSTM_ID and ustm.UserName = @UserName

				drop table if exists #JsonNewEditUserSellerTariffMappingTable 
				select USTSTM_ID = @USTSTM_ID
				,UserName = @UserName
				,IsViewOrder = @IsViewOrder
				,IsViewOrderName = (Case @IsViewOrder when 1 then 'Yes' else 'No' end)
				,IsCreateOrder = @IsCreateOrder
				,IsCreateOrderName = (Case @IsCreateOrder when 1 then 'Yes' else 'No' end)
				,IsGetQuote = @IsGetQuote
				,IsGetQuoteName = (Case @IsGetQuote when 1 then 'Yes' else 'No' end)
				,IsFinancial = @IsFinancial
				,IsFinancialName = (Case @IsFinancial when 1 then 'Yes' else 'No' end)
				,IsActive = @IsActive
				,IsActiveName = (Case @IsActive when 1 then 'Yes' else 'No' end)
				into #JsonNewEditUserSellerTariffMappingTable  

				exec [POMS_DB].[dbo].[P_User_Seller_To_Tariff_Mapping_IU_ChangeLog] @plogIsEdit = 1, @plogUserName = @ppAddedby, @plogSource_MTV_ID = @ppSource_MTV_ID

				set @ppReturn_Code = 1
				set @ppReturn_Text = 'Updated'
			end

			if @ppIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @ppReturn_Code = 1
			begin
				COMMIT; 
			end
			else if @ppIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @ppReturn_Code = 0
			begin
				ROLLBACK; 
			end

			if (@ppReturn_Code = 1)
			begin
				set @TryCount = @TryCount + 1
			end
			else
			begin
				set @TryCount = @MaxCount
			end
			
		end
		
	End Try
	Begin catch
		set @ppReturn_Code = 0
		if @ppIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @ppError_Text = 'P_User_Seller_To_Tariff_Mapping_IU: ' + ERROR_MESSAGE()
	End catch


END
GO
