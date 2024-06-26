USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_ClientSetup_DropDowns]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [dbo].[P_ClientSetup_DropDowns] 'INITIAL-COM-PUBLIC'
CREATE PROCEDURE [dbo].[P_ClientSetup_DropDowns] 
	-- Add the parameters for the stored procedure here
	 @DropId  nvarchar(120)
AS
BEGIN
	set @DropId= upper(@DropId)
 
	if @DropId ='SELLER-CODE'
	begin
		select [code]=[SELLER_KEY],[name] = [Company] + '  -  ' + [SELLER_CODE] from [POMS_DB].[dbo].[T_Seller_List] with (nolock) where IsActive = 1  order by [SELLER_CODE] asc
	end

   else if @DropId='BILLTO-CODE'
   begin
		select [code]=cast([Customer GUID] as nvarchar(36)),[name]=[Name] + '  -  ' + [No_] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where [Is Active] = 1 ORDER BY [Name]
   end

   else if @DropId='SHIPFROM-ADDRESSCODE'
   begin
		select [code]=[ADDRESS_CODE],[name]=[Address] from [POMS_DB].[dbo].[T_Address_List] with (nolock) order by [Address]
   end

   else if @DropId='DELIVERY-SERVICECODE'
   begin
		select [code]=[ST_CODE],[name]=[ServiceName] from [POMS_DB].[dbo].[T_Service_Type] tb1 with (nolock) LEFT JOIN [POMS_DB].[dbo].[T_Master_Type_Value] tb2 with (nolock) ON tb2.MTV_ID = tb1.Type_MTV_ID WHERE Type_MTV_ID = 125102 OR Type_MTV_ID = 125101 order by [ServiceName]
   end

   else if @DropId='PICKUP-SERVICECODE'
   begin
		select [code]=[ST_CODE],[name]=[ServiceName] from [POMS_DB].[dbo].[T_Service_Type] tb1 with (nolock) LEFT JOIN [POMS_DB].[dbo].[T_Master_Type_Value] tb2 with (nolock) ON tb2.MTV_ID = tb1.Type_MTV_ID WHERE Type_MTV_ID = 125100 order by [ServiceName]
   end

   else if @DropId='SELLTO-PARTNER'
   begin
		select [code] = [SELLER_PARTNER_KEY], [name] = [Company] + '  -  ' + [SELLER_PARTNER_CODE] from [POMS_DB].[dbo].[T_Seller_Partner_List] with (nolock) order by [SELLER_PARTNER_ID]
   end

   else if @DropId='ITEM-DIMENSION-UNIT'
   begin
		select [code]=[MTV_CODE],[name]=[Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 121 order by [Name]
   end

   else if @DropId='ITEM-WEIGHT-UNIT'
   begin
		select [code]=[MTV_CODE],[name]=[Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 120 order by [Name]
   end
   
   else if @DropId='ITEMTOSHIP-CODE'
   begin
		select [code]=[MTV_CODE],[name]=[Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 117 order by [Name]
   end

   else if @DropId='ITEM-CODE'
   begin
		select [code]=[MTV_CODE],[name]=[Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 118 order by [Name]
   end

   else if @DropId='ITEM-PACKINGCODE'
   begin
		select [code]=[MTV_CODE],[name]=[Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 119 order by [Name]
   end

   else if @DropId ='INITIAL-COM-PUBLIC' OR @DropId = 'INITIAL-COM-PUBLIC2'
   begin
		select [code]=1,[name]='True' union all select [code]=0,[name]='False'
   end

   else if @DropId in ('SHIPFROM-EMAIL','SHIPTO-EMAIL','ITEM-DIMENSION','PICKUP-DRIVER-INST','DELIVERY-DRIVER-INST','ORDER-INITIAL-COM','ORDER-INITIAL-COM2','ITEM-VALUE','ITEM-WEIGHT')
   begin
   select [code] = '',[name] = 'name'
   end   

END  
GO
