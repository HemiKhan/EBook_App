USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Import_File_Source_Setup]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[P_Get_Import_File_Source_Setup] -- '',0,1000,'','',30,'','',''
(	
	@Username nvarchar(150),
	@PageIndex int,  
	@PageSize int,  
	@SortExpression nvarchar(max),  
	@FilterClause nvarchar(max),  
	@TotalRowCount int OUTPUT,
	@TimeZoneID int = 0,
	@FilterObject nvarchar(max) = '',
	@ColumnObject nvarchar(max) = ''
)
AS
BEGIN 		

	IF(@FilterClause = '' OR @FilterClause = null)  
	BEGIN SET @FilterClause = ' AND 1=1' END 

	IF(@PageIndex = null)  
	BEGIN SET @PageIndex = 0 END  
  
	IF(@PageSize = null)  
	BEGIN SET @PageSize = 0 END  

	Declare @SetTop int = 30
	SET @SetTop = (@PageIndex + 1) * @PageSize

	IF len(@SortExpression) = 0  
	SET @SortExpression = ' IOFSS_ID asc '  
	ELSE
	SET @SortExpression = @SortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	Create TABLE #Table_Fields_Filter ([Code] nvarchar(150) ,[Name] nvarchar(150) ,[IsFilterApplied] bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@FilterObject)

	DROP TABLE IF exists #Table_Fields_Column
	CREATE TABLE #Table_Fields_Column ([Code] nvarchar(150) ,[Name] nvarchar(150) ,[IsColumnRequired] bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@ColumnObject)

	Declare @HideField nvarchar(50) = ',hidefield=0'
	 ---- Start Set Filter Variables
	Declare @SELLER_KEY_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'Company') then 1 else 0 end)
	Declare @FileSource_MTV_CODE_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'FileSource_MTV_CODE') then 1 else 0 end)
	Declare @OrderSubSource_MTV_CODE_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'OrderSubSource_MTV_CODE') then 1 else 0 end)
	Declare @Code_MTV_CODE_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'Code_MTV_CODE') then 1 else 0 end)
	Declare @CODE2_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'CODE2') then 1 else 0 end)
	Declare @Description_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'Description') then 1 else 0 end)
	Declare @REFNO1_Name_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'REFNO1_Name') then 1 else 0 end)
	Declare @REFNO1_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'REFNO1') then 1 else 0 end)
	Declare @REFNO2_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'REFNO2') then 1 else 0 end)
	Declare @REFNO3_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'REFNO3') then 1 else 0 end)
	Declare @IsActive_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'IsActive') then 1 else 0 end)
	Declare @AddedBy_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'AddedBy') then 1 else 0 end)
	Declare @AddedOn_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'AddedOn') then 1 else 0 end)
	Declare @ModifiedBy_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'ModifiedBy') then 1 else 0 end)
	Declare @ModifiedOn_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'ModifiedOn') then 1 else 0 end)
	---- End Set Filter Variables

	---- Start Set Column Required Variables
	Declare @SELLER_KEY_Req bit = (case when @SELLER_KEY_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'Company') then 0 else 1 end)
	Declare @FileSource_MTV_CODE_Req bit = (case when @FileSource_MTV_CODE_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'FileSource_MTV_CODE') then 0 else 1 end)
	Declare @OrderSubSource_MTV_CODE_Req bit = (case when @OrderSubSource_MTV_CODE_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'OrderSubSource_MTV_CODE') then 0 else 1 end)
	Declare @Code_MTV_CODE_Req bit = (case when @Code_MTV_CODE_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'Code_MTV_CODE') then 0 else 1 end)
	Declare @CODE2_Req bit = (case when @CODE2_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'CODE2') then 0 else 1 end)
	Declare @Description_Req bit = (case when @Description_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'Description') then 0 else 1 end)
	Declare @REFNO1_Name_Req bit = (case when @REFNO1_Name_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'REFNO1_Name') then 0 else 1 end)
	Declare @REFNO1_Req bit = (case when @REFNO1_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'REFNO1') then 0 else 1 end)
	Declare @REFNO2_Req bit = (case when @REFNO2_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'REFNO2') then 0 else 1 end)
	Declare @REFNO3_Req bit = (case when @REFNO3_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'REFNO3') then 0 else 1 end)
	Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'IsActive') then 0 else 1 end)
	Declare @AddedBy_Req bit = (case when @AddedBy_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'AddedBy') then 0 else 1 end)
	Declare @AddedOn_Req bit = (case when @AddedOn_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'AddedOn') then 0 else 1 end)
	Declare @ModifiedBy_Req bit = (case when @ModifiedBy_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'ModifiedBy') then 0 else 1 end)
	Declare @ModifiedOn_Req bit = (case when @ModifiedOn_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'ModifiedOn') then 0 else 1 end)
	---- End Set Column Required Variables

	Declare @selectSql nvarchar(max);  
	SET @selectSql = N'select IOFSS_ID = ti.IOFSS_ID, ti.SELLER_KEY'
	+ char(10) + (case when @SELLER_KEY_Filtered = 1 then '' else @HideField end) + ',Company = tb2.Company'
	+ char(10) + (case when @FileSource_MTV_CODE_Filtered = 1 then '' else @HideField end) + ',FileSource_MTV_CODE = ti.FileSource_MTV_CODE'
	+ char(10) + (case when @OrderSubSource_MTV_CODE_Filtered = 1 then '' else @HideField end) + ',OrderSubSource_MTV_CODE = ti.OrderSubSource_MTV_CODE'
	+ char(10) + (case when @Code_MTV_CODE_Filtered = 1 then '' else @HideField end) + ',Code_MTV_CODE = ti.Code_MTV_CODE'
	+ char(10) + (case when @CODE2_Filtered = 1 then '' else @HideField end) + ',CODE2 = ti.CODE2'
	+ char(10) + (case when @Description_Filtered = 1 then '' else @HideField end) + ',Description = ti.Description'
	+ char(10) + (case when @REFNO1_Name_Filtered = 1 then '' else @HideField end) + ',REFNO1_Name = [POMS_DB].[dbo].[F_Import_Order_File_Source_RefNo_Name] (ti.REFNO1,ti.Code_MTV_CODE)'
	+ char(10) + (case when @REFNO1_Filtered = 1 then '' else @HideField end) + ',REFNO1 = ti.REFNO1'
	+ char(10) + (case when @REFNO2_Filtered = 1 then '' else @HideField end) + ',REFNO2 = ti.REFNO2'
	+ char(10) + (case when @REFNO3_Filtered = 1 then '' else @HideField end) + ',REFNO3 = ti.REFNO3'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = ti.IsActive'
	+ char(10) + (case when @AddedBy_Filtered = 1 then '' else @HideField end) + ',AddedBy = ti.AddedBy'
	+ char(10) + (case when @AddedOn_Filtered = 1 then '' else @HideField end) + ',AddedOn = ti.AddedOn'
	+ char(10) + (case when @ModifiedBy_Filtered = 1 then '' else @HideField end) + ',ModifiedBy = ti.ModifiedBy'
	+ char(10) + (case when @ModifiedOn_Filtered = 1 then '' else @HideField end) + ',ModifiedOn = ti.ModifiedOn'
	+ char(10) + 'FROM [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] ti with (nolock)
	LEFT JOIN [POMS_DB].[dbo].[T_SELLER_LIST] tb2 with (nolock) ON tb2.SELLER_KEY = ti.SELLER_KEY'
	
	exec [POMS_DB].[dbo].[P_Get_Common_List] @SelectSql, @PageIndex, @PageSize, @SortExpression, @FilterClause , @SetTop , @TotalRowCount OUTPUT

END
GO
