USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Import_Order_File_Source_Setup]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [POMS_DB].[dbo].[P_Get_Import_Order_File_Source_Setup] 'AF4C1BC7-4903-4196-BE9B-D251C0A14024',null,null,null,null,'ABDULLAH.ARSHAD'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Import_Order_File_Source_Setup]
	-- Add the parameters for the stored procedure here
	@SELLER_KEY nvarchar(36)
    ,@FileSource_MTV_CODE nvarchar(20) = null
    ,@OrderSubSource_MTV_CODE nvarchar(20) = null
    ,@Code_MTV_CODE nvarchar(20) = null
    ,@CODE2 nvarchar(50) = null
    ,@Username nvarchar(150) = null
AS
BEGIN
	
	select [IOFSS_ID] ,[SELLER_KEY] ,[SELLER_CODE] ,[SELLER_NAME] ,[FileSource_MTV_CODE] ,[FileSource_MTV_Name] ,[OrderSubSource_MTV_CODE] ,[OrderSubSource_MTV_Name] 
	,[Code_MTV_CODE] ,[Code_MTV_Name] ,[CODE2] ,[Description] ,[REFNO1] ,[REFNO2] ,[REFNO3] 
	from [POMS_DB].[dbo].[F_Get_Import_Order_File_Source_Setup] (@SELLER_KEY ,@FileSource_MTV_CODE ,@OrderSubSource_MTV_CODE ,@Code_MTV_CODE ,@CODE2 ,@Username)
	
END
GO
