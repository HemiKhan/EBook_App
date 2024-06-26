USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Import_Order_File_Source_Setup]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Import_Order_File_Source_Setup] ('AF4C1BC7-4903-4196-BE9B-D251C0A14024',null,null,null,null,'ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Import_Order_File_Source_Setup]
(	
	@SELLER_KEY nvarchar(36)
    ,@FileSource_MTV_CODE nvarchar(20) = null
    ,@OrderSubSource_MTV_CODE nvarchar(20) = null
    ,@Code_MTV_CODE nvarchar(20) = null
    ,@CODE2 nvarchar(50) = null
    ,@Username nvarchar(150) = null
)
RETURNS @ReturnTable TABLE 
([IOFSS_ID] int
,[SELLER_KEY] nvarchar(36)
,[SELLER_CODE] nvarchar(50)
,[SELLER_NAME] nvarchar(250)
,[FileSource_MTV_CODE] nvarchar(20)
,[FileSource_MTV_Name] nvarchar(150)
,[OrderSubSource_MTV_CODE] nvarchar(20)
,[OrderSubSource_MTV_Name] nvarchar(150)
,[Code_MTV_CODE] nvarchar(20)
,[Code_MTV_Name] nvarchar(150)
,[CODE2] nvarchar(50)
,[Description] nvarchar(1000)
,[REFNO1] nvarchar(1000)
,[REFNO2] nvarchar(1000)
,[REFNO3] nvarchar(1000)
)
AS
begin

	set @SELLER_KEY = isnull(@SELLER_KEY,'')
	set @Username = isnull(@Username,'')

	Declare @SellerTable table (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250))
	
	insert into @SellerTable
	select SellerKey , SellerCode , SellerName from [POMS_DB].[dbo].[F_Get_SellToClientList] (@SELLER_KEY,null)
	
	insert into @ReturnTable
	select iofss.[IOFSS_ID] 
	,st.[SellerKey] 
	,st.[SellerCode]
	,st.[SellerName]
	,iofss.[FileSource_MTV_CODE] 
	,[FileSource_MTV_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (iofss.[FileSource_MTV_CODE])
	,iofss.[OrderSubSource_MTV_CODE] 
	,[OrderSubSource_MTV_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (iofss.[OrderSubSource_MTV_CODE])
	,iofss.[Code_MTV_CODE] 
	,[Code_MTV_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (iofss.[Code_MTV_CODE])
	,iofss.[CODE2] 
	,iofss.[Description] 
	,iofss.[REFNO1] 
	,iofss.[REFNO2] 
	,iofss.[REFNO3]
	from [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] iofss with (nolock)
	inner join @SellerTable st on iofss.[SELLER_KEY] = st.SellerKey
	where iofss.IsActive = 1
	and (iofss.FileSource_MTV_CODE = @FileSource_MTV_CODE or @FileSource_MTV_CODE is null)
    and (iofss.OrderSubSource_MTV_CODE = @OrderSubSource_MTV_CODE or @OrderSubSource_MTV_CODE is null)
    and (iofss.Code_MTV_CODE = @Code_MTV_CODE or @Code_MTV_CODE is null)
    and (iofss.CODE2 = @CODE2 or @CODE2 is null)

	return
	

end
GO
