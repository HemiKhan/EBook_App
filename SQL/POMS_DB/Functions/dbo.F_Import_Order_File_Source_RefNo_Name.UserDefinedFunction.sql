USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Import_Order_File_Source_RefNo_Name]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

CREATE FUNCTION [dbo].[F_Import_Order_File_Source_RefNo_Name]  
(
	@REFNO1 nvarchar(1000)
	,@Code_MTV_CODE nvarchar(20)
)
RETURNS nvarchar(250)
AS
BEGIN
	
	Declare @Ret nvarchar(250) = ''

	set @Code_MTV_CODE = isnull(@Code_MTV_CODE,'')

	if @Code_MTV_CODE ='SELLER-CODE'
	begin
		select @Ret = [Company] from [POMS_DB].[dbo].[T_Seller_List] with (nolock) where SELLER_KEY = @REFNO1
	end

   else if @Code_MTV_CODE='BILLTO-CODE'
   begin
		select @Ret=[Name] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where [Customer GUID] = @REFNO1
   end

   else if @Code_MTV_CODE='SHIPFROM-ADDRESSCODE'
   begin
		select @Ret=[Address] from [POMS_DB].[dbo].[T_Address_List] with (nolock) where ADDRESS_CODE = @REFNO1
   end

   else if @Code_MTV_CODE in ('PICKUP-SERVICECODE','DELIVERY-SERVICECODE')
   begin
		select @Ret=[ServiceName] from [POMS_DB].[dbo].[T_Service_Type] tb1 with (nolock) where ST_CODE = @REFNO1
   end

   else if @Code_MTV_CODE='SELLTO-PARTNER'
   begin
		select @Ret=[SELLER_PARTNER_KEY] from [POMS_DB].[dbo].[T_Seller_Partner_List] with (nolock) where [SELLER_PARTNER_CODE] = @REFNO1
   end

   else if @Code_MTV_CODE in ('ITEM-DIMENSION-UNIT','ITEM-WEIGHT-UNIT','ITEMTOSHIP-CODE','ITEM-CODE','ITEM-PACKINGCODE')
   begin
		select @Ret=[Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where [MTV_CODE] = @REFNO1
   end

   else if @Code_MTV_CODE in ('INITIAL-COM-PUBLIC','INITIAL-COM-PUBLIC2')
   begin
		select @Ret=(case when @REFNO1 = '1' then 'True' else 'False' end)
   end

   else 
   begin
		select @Ret = ''
   end  

   set @Ret = isnull(@Ret,'')

	return @Ret
END
GO
