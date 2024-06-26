USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Search_Sku_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_Search_Sku_List] 0,'AD330B2D-DC87-4512-88B4-C8D5ECCE8B38','78','ABDULLAH.ARSHAD',1,0
-- [P_Get_Search_Sku_List] 83801,'AD330B2D-DC87-4512-88B4-C8D5ECCE8B38','','ABDULLAH.ARSHAD',1,1
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Search_Sku_List]
	@SSS_ID int = 0
	,@SELLER_KEY nvarchar(36)
	,@SearchSKU nvarchar(150)
	,@Username nvarchar(150)
	,@IsReturnFullList bit = 1
	,@IsMasterSku bit = 0
AS
BEGIN
	
	set @SSS_ID = isnull(@SSS_ID,0)
	set @IsReturnFullList = isnull(@IsReturnFullList,0)
	set @IsMasterSku = isnull(@IsMasterSku,0)

	Declare @SSS_IDsTable table (SSS_ID int, IsMasterSKU bit)
	if @SSS_ID = 0
	begin
		insert into @SSS_IDsTable
		select SSS_ID,IsMasterSKU from [POMS_DB].[dbo].[F_Get_Search_Sku_And_Desc] (@SELLER_KEY, @SearchSKU, 30, @Username)
	end
	else
	begin
		if (@IsMasterSku = 0)
		begin
			insert into @SSS_IDsTable
			select @SSS_ID,@IsMasterSku 
		end
		if (@IsMasterSku = 1)
		begin
			Declare @MasterSKU_No nvarchar(150) = ''
			select @MasterSKU_No = sss.MasterSKU_No from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.SSS_ID = @SSS_ID and sss.IsActive = 1 
			and sss.SELLER_KEY = @SELLER_KEY and sss.IsMasterSKU = 1
			set @MasterSKU_No = isnull(@MasterSKU_No,'')

			if @MasterSKU_No != ''
			begin
				insert into @SSS_IDsTable
				select sss.SSS_ID, IsMasterSKU = 0 from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.IsActive = 1 
				and sss.SELLER_KEY = @SELLER_KEY and sss.IsMasterSKU = 1 and sss.MasterSKU_No =  @MasterSKU_No
			end

		end
	end

	Declare @ReturnTable table 
	(ID int identity(1,1) not null
	,SSS_ID int
	,Type_MTV_CODE nvarchar(20)
	,SKU_No nvarchar(150)
	,[Description] nvarchar(500)
	,IsMasterSKU bit
	,[Weight] decimal(18,6)
	,WeightUnit_MTV_CODE nvarchar(20)
	,DimLength decimal(18,6)
	,DimWidth decimal(18,6)
	,DimHeight decimal(18,6)
	,DimUnit_MTV_CODE nvarchar(20)
	,CalculatedCuFt1 decimal(18,6)
	,UserCuFt decimal(18,6)
	,[Value] decimal(18,6)
	,[AssemblyTime] int
	,Sort_ int)

	if (@IsReturnFullList = 1)
	begin
		insert into @ReturnTable (SSS_ID ,Type_MTV_CODE ,SKU_No ,[Description] ,IsMasterSKU ,[Weight] ,WeightUnit_MTV_CODE ,DimLength ,DimWidth ,DimHeight ,DimUnit_MTV_CODE 
		,CalculatedCuFt1 ,UserCuFt ,[Value] ,[AssemblyTime] ,Sort_)
		select * from (
			select SSS_ID ,Type_MTV_CODE ,SKU_No = MasterSKU_No ,[Description] = [MasterSKUDescription] ,[IsMasterSku] = 1 ,[Weight] ,[WeightUnit_MTV_CODE] ,[DimLength] ,[DimWidth] ,[DimHeight] ,[DimUnit_MTV_CODE]
			,[CalculatedCuFt] ,[UserCuFt] ,[Value] ,[AssemblyTime] ,[Sort_]
			from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.SSS_ID in (select s.SSS_ID from @SSS_IDsTable s where s.IsMasterSKU = 1)
			--order by MasterSku_No, SKU_No, [Sort_]

			union

			select SSS_ID ,Type_MTV_CODE ,SKU_No ,[Description] ,[IsMasterSku] = 0 ,[Weight] ,[WeightUnit_MTV_CODE] ,[DimLength] ,[DimWidth] ,[DimHeight] ,[DimUnit_MTV_CODE]
			,[CalculatedCuFt] ,[UserCuFt] ,[Value] ,[AssemblyTime] ,[Sort_]
			from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.SSS_ID in (select s.SSS_ID from @SSS_IDsTable s where s.IsMasterSKU = 0)
			--order by MasterSku_No, SKU_No, [Sort_]
		) ilv order by SSS_ID, IsMasterSKU desc, [Sort_] asc
		--order by SKU_No asc, [Description] asc, [Sort_] asc
	end
	else if (@IsReturnFullList = 0)
	begin
		insert into @ReturnTable (SSS_ID ,Type_MTV_CODE ,SKU_No ,[Description] ,IsMasterSKU ,[Weight] ,WeightUnit_MTV_CODE ,DimLength ,DimWidth ,DimHeight ,DimUnit_MTV_CODE 
		,CalculatedCuFt1 ,UserCuFt ,[Value] ,[AssemblyTime] ,Sort_)
		select * from (
			select SSS_ID ,Type_MTV_CODE ,SKU_No = MasterSKU_No ,[Description] = [MasterSKUDescription] ,[IsMasterSku] = 1 ,[Weight] ,[WeightUnit_MTV_CODE] ,[DimLength] ,[DimWidth] ,[DimHeight] ,[DimUnit_MTV_CODE]
			,[CalculatedCuFt] ,[UserCuFt] ,[Value] ,[AssemblyTime] ,[Sort_]
			from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.SSS_ID in (select s.SSS_ID from @SSS_IDsTable s where s.IsMasterSKU = 1)
			--order by MasterSku_No, SKU_No, [Sort_]

			union

			select SSS_ID ,Type_MTV_CODE ,SKU_No ,[Description] ,[IsMasterSku] = 0 ,[Weight] ,[WeightUnit_MTV_CODE] ,[DimLength] ,[DimWidth] ,[DimHeight] ,[DimUnit_MTV_CODE]
			,[CalculatedCuFt] ,[UserCuFt] ,[Value] ,[AssemblyTime] ,[Sort_]
			from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.SSS_ID in (select s.SSS_ID from @SSS_IDsTable s where s.IsMasterSKU = 0)
			--order by MasterSku_No, SKU_No, [Sort_]
		) ilv order by SKU_No, SSS_ID, IsMasterSKU desc, [Sort_] asc
		--order by SKU_No asc, [Description] asc, [Sort_] asc
	end

	select * from @ReturnTable order by ID

END
GO
