USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Price_Key]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Price_Key] ('42A988E7-12FA-48B6-BF38-EF900E6ED9AB', '', '', '', '', '')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Price_Key]
(	
	@SellToCustomerKey nvarchar(36)
	,@SubSellToCustomerKey nvarchar(36)
	,@SellToPartnerKey nvarchar(36)
	,@TariffNo nvarchar(36)
	,@BillToCustomerKey nvarchar(36)
	,@Username nvarchar(150)
)
returns @ReturnTable table
(pricekey nvarchar(36)
,pricekeyname nvarchar(150)
,isactive bit
,isautogetpinnacle bit
,isenablegreenbutton bit
,isactiveinpinnacle bit
,isadvancequote bit
,isstandardquote bit
,isquickquote bit
,issearchquote bit
,isisgettrackingnoquote bit
,isquickbulkquote bit
)
AS
Begin

	set @SellToCustomerKey = isnull(@SellToCustomerKey,'')
	set @SubSellToCustomerKey = isnull(@SubSellToCustomerKey,'')
	set @SellToPartnerKey = isnull(@SellToPartnerKey,'')
	set @TariffNo = isnull(@TariffNo,'')
	set @BillToCustomerKey = isnull(@BillToCustomerKey,'')
	set @Username = isnull(@Username,'')

	insert into @ReturnTable (pricekey ,pricekeyname ,isactive ,isautogetpinnacle ,isenablegreenbutton ,isactiveinpinnacle ,isadvancequote ,isstandardquote ,isquickquote ,issearchquote 
	,isisgettrackingnoquote ,isquickbulkquote)
	select P_Key,Remarks,Is_Active,Is_Auto_Get_Pinnacle,Is_Enable_Green_Button,Is_Active_In_Pinnacle,Is_Advance_Quote,Is_Standard_Quote,Is_Quick_Quote,Is_Search_Quote,Is_Get_TrackingNo_Quote,Is_Quick_Bulk_Quote from [Quotes].[dbo].[T_Price_Key] with (nolock) where isnull(Client_ID,'') = 'C100052'

	return

end
GO
