USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMSArchive_OrderDetail_Special_Service_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMSArchive_OrderDetail_Special_Service_By_OrderID] (10100238,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMSArchive_OrderDetail_Special_Service_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
returns @ReturnTable table
(ORDER_ID int
,SSL_CODE nvarchar(20)
,[Name] nvarchar(100)
,Is_Pickup bit
,Description_ nvarchar(250)
,Mints int 
,Floor_ int
,EST_Amount decimal(18,2)
,Days_ int
,From_Date date
,To_Date date
,Man int
,IsPublic bit
)
AS
Begin
	
	insert into @ReturnTable (ORDER_ID ,SSL_CODE ,[Name] ,Is_Pickup ,Description_ ,Mints ,Floor_ ,EST_Amount ,Days_ ,From_Date ,To_Date ,Man ,IsPublic)
	SELECT [ORDER_ID]
	,ssl_.SSL_CODE
	,ssl_.[Name]
	,[Is_Pickup]
	,[Description_]
	,[Mints]
	,[Floor_]
	,[EST_Amount]
	,[Days_]
	,[From_Date]
	,[To_Date]
	,[Man]
	,[IsPublic]
	FROM [POMSArchive_DB].[dbo].[T_Order_Special_Service] oss with (nolock) 
	inner join [POMS_DB].[dbo].[T_Service_Level_Special_Service] slss with (nolock) on slss.SLSS_ID = oss.SLSS_ID
	inner join [POMS_DB].[dbo].[T_Special_Services_List] ssl_ with (nolock) on slss.SSL_CODE = ssl_.SSL_CODE
	where oss.ORDER_ID = @ORDER_ID

	return

end
GO
