USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonItemsTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_JsonItemsTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonItemsTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
([RequestItemID] nvarchar(50) NULL,
[RowNo] int NULL,
[OI_ID] int NULL,
[PARENT_OI_ID] int NULL,
[ORDER_ID] int NULL,
[BARCODE] nvarchar(20) NULL,
[BARCODE_GUID] nvarchar(36) NULL,
--[LineNo_] int IDENTITY(10000,10000) NOT NULL,
[ItemToShip_MTV_CODE] nvarchar(20) NULL,
[ItemCode_MTV_CODE] nvarchar(20) NULL,
[PackingCode_MTV_CODE] nvarchar(20) NULL,
[SKU_NO] nvarchar(150) NULL,
[ItemDescription] nvarchar(250) NULL,
[Quantity] int NULL,
[ItemWeight] decimal(18, 6) NULL,
[WeightUnit_MTV_CODE] nvarchar(20) NULL,
[ItemLength] decimal(18, 6) NULL,
[ItemWidth] decimal(18, 6) NULL,
[ItemHeight] decimal(18, 6) NULL,
[Dimensions] nvarchar(50) NULL,
[DimensionUnit_MTV_CODE] nvarchar(20) NULL,
[Cu_Ft_] decimal(18, 6) NULL,
[Amount] decimal(18, 6) NULL,
[AssemblyTime] int NULL,
[PackageDetailsNote] nvarchar(250) NULL,
[ItemClientRef1] nvarchar(150) NULL,
[ItemClientRef2] nvarchar(150) NULL,
[ItemClientRef3] nvarchar(150) NULL,
[ItemImages] nvarchar(max) NULL,
[IsAddItem] bit NULL,
[IsEditItem] bit NULL,
[IsDeleteItem] bit NULL
)
AS
begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end
	
	insert into @ReturnTable ([RequestItemID] ,[RowNo] ,[OI_ID] ,[PARENT_OI_ID] ,[ORDER_ID] ,[BARCODE] ,[BARCODE_GUID] ,[ItemToShip_MTV_CODE] ,[ItemCode_MTV_CODE] ,[PackingCode_MTV_CODE] 
	,[SKU_NO] ,[ItemDescription] ,[Quantity] ,[ItemWeight] ,[WeightUnit_MTV_CODE] ,[ItemLength] ,[ItemWidth] ,[ItemHeight] ,[Dimensions] ,[DimensionUnit_MTV_CODE] ,[Cu_Ft_] 
	,[Amount] ,[AssemblyTime] ,[PackageDetailsNote] ,[ItemClientRef1] ,[ItemClientRef2] ,[ItemClientRef3] ,[ItemImages] ,[IsAddItem] ,[IsEditItem] ,[IsDeleteItem])
	select ilv.RequestItemID ,ilv.RowNo ,OI_ID = isnull(ilv.OI_ID,0) ,ilv.PARENT_OI_ID ,Order_ID = null ,ilv.Barcode ,ilv.BarcodeGUID ,ilv.ItemToShip_MTV_CODE ,ilv.ItemCode_MTV_CODE ,ilv.PackingCode_MTV_CODE 
	,ilv.SKU_NO ,ilv.ItemDescription ,Quantity = 1 ,ilv.ItemWeight ,ilv.WeightUnit_MTV_CODE ,ilv.ItemLength ,ilv.ItemWidth ,ilv.ItemHeight 
	,Dimension = (cast(ItemLength as nvarchar(15)) + ' x ' + cast(ItemWidth as nvarchar(15)) + ' x ' + cast(ItemHeight as nvarchar(15)))
	,ilv.DimensionUnit_MTV_CODE ,ilv.Cu_Ft_ ,ilv.Amount ,ilv.AssemblyTime ,ilv.PackageDetailsNote ,ilv.ItemClientRef1 ,ilv.ItemClientRef2 ,ilv.ItemClientRef3 ,ilv.itemimage 
	,[IsAddItem] = (case when isnull(ilv.OI_ID,0) = 0 and isnull([IsDeleteItem],0) = 0 then 1 else 0 end)
	,[IsEditItem] = (case when isnull(ilv.OI_ID,0) > 0 and isnull([IsDeleteItem],0) = 0 then 1 else 0 end)
	,[IsDeleteItem] = isnull([IsDeleteItem],0)
	from (
		select items.*,items2.*
		from OpenJson(@Json)
		WITH (
			RequestItemID nvarchar(150) '$.requestitemid'
			,RowNo int '$.rowno'
			,OI_ID int '$.itemid'
			,PARENT_OI_ID int '$.parentitemid'
			,ItemToShip_MTV_CODE nvarchar(20) '$.itemtoship'
			,ItemCode_MTV_CODE nvarchar(20) '$.itemcode'
			,PackingCode_MTV_CODE nvarchar(20) '$.packingcode'
			,SKU_NO nvarchar(150) '$.skuno'
			,ItemDescription nvarchar(250) '$.description'
			,Quantity int '$.quantity'
			,ItemWeight decimal(18,6) '$.itemweight'
			,WeightUnit_MTV_CODE nvarchar(20) '$.weightunit'
			,ItemLength float '$.boxlength'
			,ItemWidth float '$.boxwidth'
			,ItemHeight float '$.boxheight'
			,Dimension nvarchar(50) '$.dimension'
			,DimensionUnit_MTV_CODE nvarchar(20) '$.dimensionunit'
			,Cu_Ft_ decimal(18,6) '$.calculatedcuft'
			,Amount decimal(18,6) '$.itemamount'
			,AssemblyTime int '$.itemassemblytime'
			,PackageDetailsNote nvarchar(250) '$.packagedetailsnote'
			,ItemClientRef1 nvarchar(150) '$.itemclientref1'
			,ItemClientRef2 nvarchar(150) '$.itemclientref2'
			,ItemClientRef3 nvarchar(150) '$.itemclientref3'
			,IsDeleteItem bit '$.isdeleteitem'
			,itemimage nvarchar(max) '$.itemimages' as json
			,barcodelist nvarchar(max) '$.barcodes' as json
		) items
		OUTER APPLY OpenJson(items.barcodelist)
		WITH (
			Barcode nvarchar(20) '$.barcode'
			,BarcodeGUID nvarchar(36) '$.barcodeguid'
		) items2
	) ilv where ilv.RowNo is not null
	order by ilv.Barcode,ilv.RowNo

	return

end
GO
