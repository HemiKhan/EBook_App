USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_Special_Service_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_Special_Service_By_OrderID] (10100238,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_Special_Service_By_OrderID]
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
	
	return

end
GO
