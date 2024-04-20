USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ShipmentType_From_ServiceLevel]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_ShipmentType_From_ServiceLevel]
	@ST_CODE nvarchar(20)
AS
BEGIN
	
	Declare @ShipmentType_MTV_ID int = 0
	Select @ShipmentType_MTV_ID = [POMS_DB].[dbo].[F_Get_ShipmentType_From_ServiceLevel] (@ST_CODE)
	select @ShipmentType_MTV_ID as ShipmentType_MTV_ID 

END
GO
