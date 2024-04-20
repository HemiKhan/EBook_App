USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_Import_Fields_Name_Setting]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Seller_Import_Fields_Name_Setting] ('9A84FB40-6AF0-465A-936C-13139909FEEC', 'EXCEL')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_Import_Fields_Name_Setting]
(	
	@SELLER_KEY nvarchar(36)
	,@OrderSubSource_MTV_CODE nvarchar(20)
)
returns @ReturnTable table
(SellerKey nvarchar(36)
,SellerCode nvarchar(20)
,SellerName nvarchar(250)
,[OIFFN_ID] int
,[OrderSubSource_MTV_CODE] nvarchar(20)
,[UniqueIDForOrderImport] nvarchar(50)
,[OriginalFieldName] nvarchar(50)
,[FieldName] nvarchar(50)
,[Description] nvarchar(1000)
,[SetType_MTV_ID] int
,[FieldType_MTV_ID] int
,[OriginalRequired] bit
,[IsRequired] bit
,[IsCustomAllowed] bit
,[OriginalIsActive] bit
,[IsActive] bit
)
AS
Begin
	
	set @SELLER_KEY = isnull(@SELLER_KEY,'')

	if (@SELLER_KEY = '')
	begin
		insert into @ReturnTable
		select * from (
			select SellerKey=ilv.SELLER_KEY
			,SellerCode=ilv.SELLER_CODE
			,[SellerName]=ilv.Company
			,ilv.[OIFFN_ID]
			,ilv.[OrderSubSource_MTV_CODE]
			,ilv.[UniqueIDForOrderImport]
			,[OriginalFieldName]=ilv.[OriginalFieldName]
			,[FieldName]=isnull(ilv.[FieldName],ilv.[OriginalFieldName])
			,ilv.[Description]
			,[SetType_MTV_ID]=ilv.[SetType_MTV_ID]
			,[FieldType_MTV_ID]=ilv.[FieldType_MTV_ID]
			,[OriginalRequired]=ilv.[IsRequired]
			,[IsRequired]=ilv.[IsRequired]
			,[IsCustomAllowed]=ilv.[IsCustomAllowed]
			,[OriginalIsActive]=ilv.[IsActive]
			,[IsActive]=ilv.[IsActive]
			from (
				SELECT oiffn.[OIFFN_ID]
					,oiffn.[OrderSubSource_MTV_CODE]
					,[UniqueIDForOrderImport]=(select REFNO1 from [POMS_DB].[dbo].[F_Get_Default_Value] ('','UNIQUE_ID_FOR_ORDER_IMPORT'))
					,oiffn.[OriginalFieldName]
					,oiffn.[FieldName]
					,oiffn.[Description]
					,oiffn.[SetType_MTV_ID]
					,oiffn.[FieldType_MTV_ID]
					,oiffn.[IsRequired]
					,oiffn.[IsCustomAllowed]
					,oiffn.[IsActive]
					,SELLER_CODE=''
					,SELLER_KEY=''
					,Company=''
				FROM [POMS_DB].[dbo].[T_Order_Import_File_Fields_Name] oiffn with (nolock)
				where oiffn.OrderSubSource_MTV_CODE = @OrderSubSource_MTV_CODE
			) ilv 
		) ilv2 where ilv2.IsActive = 1
	end
	else
	begin
		insert into @ReturnTable
		select * from (
			select SellerKey=ilv.SELLER_KEY
			,SellerCode=ilv.SELLER_CODE
			,[SellerName]=ilv.Company
			,ilv.[OIFFN_ID]
			,ilv.[OrderSubSource_MTV_CODE]
			,ilv.[UniqueIDForOrderImport]
			,[OriginalFieldName]=ilv.[OriginalFieldName]
			,[FieldName]=isnull(siffn.[FieldName],isnull(ilv.[FieldName],ilv.[OriginalFieldName]))
			,ilv.[Description]
			,[SetType_MTV_ID]=ISNULL(siffn.[SetType_MTV_ID],ilv.[SetType_MTV_ID])
			,[FieldType_MTV_ID]=ilv.[FieldType_MTV_ID]
			,[OriginalRequired]=ilv.[IsRequired]
			,[IsRequired]=isnull(siffn.[IsRequired],ilv.[IsRequired])
			,[IsCustomAllowed]=ilv.[IsCustomAllowed]
			,[OriginalIsActive]=ilv.[IsActive]
			,[IsActive]=isnull(siffn.[IsActive],ilv.[IsActive])
			from (
				SELECT oiffn.[OIFFN_ID]
					,oiffn.[OrderSubSource_MTV_CODE]
					,[UniqueIDForOrderImport]=(select REFNO1 from [POMS_DB].[dbo].[F_Get_Default_Value] (sl.SELLER_CODE,'UNIQUE_ID_FOR_ORDER_IMPORT'))
					,oiffn.[OriginalFieldName]
					,oiffn.[FieldName]
					,oiffn.[Description]
					,oiffn.[SetType_MTV_ID]
					,oiffn.[FieldType_MTV_ID]
					,oiffn.[IsRequired]
					,oiffn.[IsCustomAllowed]
					,oiffn.[IsActive]
					,sl.SELLER_CODE
					,sl.SELLER_KEY
					,sl.Company
				FROM [POMS_DB].[dbo].[T_Order_Import_File_Fields_Name] oiffn with (nolock)
				cross apply [POMS_DB].[dbo].[T_Seller_List] sl with (nolock)
				where sl.SELLER_KEY = @SELLER_KEY and sl.IsActive = 1 and oiffn.OrderSubSource_MTV_CODE = @OrderSubSource_MTV_CODE
			) ilv left join [POMS_DB].[dbo].[T_Seller_Import_File_Fields_Name] siffn with (nolock) on ilv.OIFFN_ID = siffn.OIFFN_ID and ilv.SELLER_CODE = siffn.SELLER_CODE
		) ilv2 where ilv2.IsActive = 1
	end

	return

end
GO
