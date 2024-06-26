USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Order_Process_Log]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @TotalCount int = 0 exec [dbo].[P_Get_Order_Process_Log] 'ABDULLAH.ARSHAD', 0, 30, '', ' ', @TotalCount out, 13, '', '' select @TotalCount
-- ============================================='  
CREATE PROCEDURE [dbo].[P_Get_Order_Process_Log]
	-- Add the parameters for the stored procedure here
	@Username nvarchar(150),
	@PageIndex int,  
	@PageSize int,  
	@SortExpression varchar(max),  
	@FilterClause varchar(max),  
	@TotalRowCount int OUTPUT,
	@TimeZoneID int = 13,
	@FilterObject nvarchar(max) = '',
	@ColumnObject nvarchar(max) = ''
	
AS
Begin
	
	if isnull(@FilterClause,'') = ''
		begin set @FilterClause = ' AND 1 = 1 ' end

	if isnull(@PageIndex,0) <= 0
		begin set @PageIndex = 0 end

	if isnull(@PageSize,0) <= 0  
		begin set @PageSize = 0 end

	Declare @SetTop int = 30
	if @PageSize <> 0
		begin set @SetTop = (@PageIndex + 1) * @PageSize end

	set @SortExpression = ltrim(rtrim(@SortExpression))
	if len(@SortExpression) = 0  
		set @SortExpression = ' OPL_ID desc '  
	else
		set @SortExpression = ' ' + @SortExpression + ' '  
  
	drop table if exists #Table_Fields_Filter
	Create table #Table_Fields_Filter (Code nvarchar(150) ,Name_ nvarchar(150) ,IsFilterApplied bit)
	insert into #Table_Fields_Filter (Code ,Name_ ,IsFilterApplied )
	select [Code],[Name],[IsFilterApplied] from [POMS_DB].[dbo].[F_Get_Table_Fields_Filter] (@FilterObject)
  
	drop table if exists #Table_Fields_Column
	Create table #Table_Fields_Column (Code nvarchar(150) ,Name_ nvarchar(150) ,IsColumnRequired bit)
	insert into #Table_Fields_Column (Code ,Name_ ,IsColumnRequired )
	select [Code],[Name],[IsColumnRequired] from [POMS_DB].[dbo].[F_Get_Table_Fields_Column] (@ColumnObject)

	Declare @HideField nvarchar(50) = ',hidefield=0'
    --hidefield=0, add this in column start this means ignore this fields while getting totalrowcount

    ---- Start Set Filter Variables
	Declare @RequestID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RequestID') then 1 else 0 end)
	Declare @IsSuccess_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsSuccess') then 1 else 0 end)
	Declare @UniqueID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UniqueID') then 1 else 0 end)
	Declare @Status_MTV_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status_MTV_CODE') then 1 else 0 end)
	Declare @ErrorJson_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ErrorJson') then 1 else 0 end)
	Declare @WarningJson_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'WarningJson') then 1 else 0 end)
	Declare @PickupServiceCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PickupServiceCode') then 1 else 0 end)
	Declare @DeliveryServiceCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DeliveryServiceCode') then 1 else 0 end)
	Declare @TotalQty_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalQty') then 1 else 0 end)
	Declare @TotalWeight_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalWeight') then 1 else 0 end)
	Declare @TotalCuft_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalCuft') then 1 else 0 end)
	Declare @TotalValue_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalValue') then 1 else 0 end)
	Declare @PRO_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PRO') then 1 else 0 end)
	Declare @PONUMBER_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PONUMBER') then 1 else 0 end)
	Declare @REF2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REF2') then 1 else 0 end)
	Declare @CarrierCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CarrierCode') then 1 else 0 end)
	Declare @ORDER_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ORDER_ID') then 1 else 0 end)
	Declare @TRACKING_NO_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TRACKING_NO') then 1 else 0 end)
	Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
	Declare @AddedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedBy') then 1 else 0 end)
	Declare @AddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedOn') then 1 else 0 end)
	Declare @ModifiedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedBy') then 1 else 0 end)
	Declare @ModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedOn') then 1 else 0 end)
	---- End Set Filter Variables
  
	---- Start Set Column Required Variables
	Declare @RequestID_Req bit = (case when @RequestID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RequestID') then 0 else 1 end)
	Declare @IsSuccess_Req bit = (case when @IsSuccess_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsSuccess') then 0 else 1 end)
	Declare @UniqueID_Req bit = (case when @UniqueID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UniqueID') then 0 else 1 end)
	Declare @Status_MTV_CODE_Req bit = (case when @Status_MTV_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status_MTV_CODE') then 0 else 1 end)
	Declare @ErrorJson_Req bit = (case when @ErrorJson_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ErrorJson') then 0 else 1 end)
	Declare @WarningJson_Req bit = (case when @WarningJson_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'WarningJson') then 0 else 1 end)
	Declare @PickupServiceCode_Req bit = (case when @PickupServiceCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PickupServiceCode') then 0 else 1 end)
	Declare @DeliveryServiceCode_Req bit = (case when @DeliveryServiceCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DeliveryServiceCode') then 0 else 1 end)
	Declare @TotalQty_Req bit = (case when @TotalQty_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalQty') then 0 else 1 end)
	Declare @TotalWeight_Req bit = (case when @TotalWeight_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalWeight') then 0 else 1 end)
	Declare @TotalCuft_Req bit = (case when @TotalCuft_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalCuft') then 0 else 1 end)
	Declare @TotalValue_Req bit = (case when @TotalValue_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalValue') then 0 else 1 end)
	Declare @PRO_Req bit = (case when @PRO_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PRO') then 0 else 1 end)
	Declare @PONUMBER_Req bit = (case when @PONUMBER_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PONUMBER') then 0 else 1 end)
	Declare @REF2_Req bit = (case when @REF2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REF2') then 0 else 1 end)
	Declare @CarrierCode_Req bit = (case when @CarrierCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CarrierCode') then 0 else 1 end)
	Declare @ORDER_ID_Req bit = (case when @ORDER_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ORDER_ID') then 0 else 1 end)
	Declare @TRACKING_NO_Req bit = (case when @TRACKING_NO_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TRACKING_NO') then 0 else 1 end)
	Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
	Declare @AddedBy_Req bit = (case when @AddedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedBy') then 0 else 1 end)
	Declare @AddedOn_Req bit = (case when @AddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedOn') then 0 else 1 end)
	Declare @ModifiedBy_Req bit = (case when @ModifiedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedBy') then 0 else 1 end)
	Declare @ModifiedOn_Req bit = (case when @ModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedOn') then 0 else 1 end)
	---- End Set Column Required Variables
  
	Declare @selectSql nvarchar(max); 
   
	set @selectSql = N'select opl.OPL_ID '
	+ char(10) + (case when @RequestID_Filtered = 1 then '' else @HideField end) + ',opl.RequestID '
	+ char(10) + (case when @IsSuccess_Filtered = 1 then '' else @HideField end) + ',opl.IsSuccess '
	+ char(10) + (case when @UniqueID_Filtered = 1 then '' else @HideField end) + ',opl.UniqueID '
	+ char(10) + (case when @Status_MTV_CODE_Filtered = 1 then '' else @HideField end) + ',opl.Status_MTV_CODE '
	+ char(10) + (case when @ErrorJson_Filtered = 1 then '' else @HideField end) + ',opl.ErrorJson '
	+ char(10) + (case when @WarningJson_Filtered = 1 then '' else @HideField end) + ',opl.WarningJson '
	+ char(10) + (case when @PickupServiceCode_Filtered = 1 then '' else @HideField end) + ',opl.PickupServiceCode '
	+ char(10) + (case when @DeliveryServiceCode_Filtered = 1 then '' else @HideField end) + ',opl.DeliveryServiceCode '
	+ char(10) + (case when @TotalQty_Filtered = 1 then '' else @HideField end) + ',opl.TotalQty '
	+ char(10) + (case when @TotalWeight_Filtered = 1 then '' else @HideField end) + ',opl.TotalWeight '
	+ char(10) + (case when @TotalCuft_Filtered = 1 then '' else @HideField end) + ',opl.TotalCuft '
	+ char(10) + (case when @TotalValue_Filtered = 1 then '' else @HideField end) + ',opl.TotalValue '
	+ char(10) + (case when @PRO_Filtered = 1 then '' else @HideField end) + ',opl.PRO '
	+ char(10) + (case when @PONUMBER_Filtered = 1 then '' else @HideField end) + ',opl.PONUMBER '
	+ char(10) + (case when @REF2_Filtered = 1 then '' else @HideField end) + ',opl.REF2 '
	+ char(10) + (case when @CarrierCode_Filtered = 1 then '' else @HideField end) + ',opl.CarrierCode '
	+ char(10) + (case when @ORDER_ID_Filtered = 1 then '' else @HideField end) + ',opl.ORDER_ID '
	+ char(10) + (case when @TRACKING_NO_Filtered = 1 then '' else @HideField end) + ',opl.TRACKING_NO '
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',opl.IsActive '
	+ char(10) + (case when @AddedBy_Filtered = 1 then '' else @HideField end) + ',opl.AddedBy '
	+ char(10) + (case when @AddedOn_Filtered = 1 then '' else @HideField end) + ',opl.AddedOn '
	+ char(10) + (case when @ModifiedBy_Filtered = 1 then '' else @HideField end) + ',opl.ModifiedBy '
	+ char(10) + (case when @ModifiedOn_Filtered = 1 then '' else @HideField end) + ',opl.ModifiedOn '
	+ char(10) + ' from [POMS_DB].[dbo].[T_Order_Process_Log] opl with (nolock)
	where opl.IsActive = 1 '

	exec [POMS_DB].[dbo].[P_Get_Common_List] @SelectSql, @PageIndex, @PageSize, @SortExpression, @FilterClause , @SetTop , @TotalRowCount OUTPUT

END

GO
