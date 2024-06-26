USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_LogiwaClient_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[P_Get_LogiwaClient_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT [value] = SELLER_KEY , [text] = Company + '  -  ' + SELLER_CODE FROM [POMS_DB].[dbo].[T_Seller_List] WHERE IsActive = 1 ORDER BY Company
	
	SELECT [value] = CAST([Customer GUID] as nvarchar(50)), [text] = [Name] + '  -  ' + No_ FROM [MetroPolitanNavProduction].dbo.[Metropolitan$Customer] WHERE [Is Active] = 1 ORDER BY Name

	SELECT [value] = USERNAME , [text] = [USERNAME] FROM [POMS_DB].[dbo].[T_Clients_Users_Mapping] WHERE [IsActive] = 1 ORDER BY USERNAME
END
GO
