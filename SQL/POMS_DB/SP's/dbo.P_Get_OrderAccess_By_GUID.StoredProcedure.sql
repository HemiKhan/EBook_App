USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_OrderAccess_By_GUID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================
-- exec [dbo].[P_Get_OrderAccess_By_GUID] '81476343-24DE-48B6-B53F-FDFDB66BC616',0,'MATEEN','METRO-USER',147100
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_OrderAccess_By_GUID]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@GetRecordType_MTV_ID int
)

AS

BEGIN

select ReturnCode ,ReturnText ,Order_ID = ORDER_ID, RecordType_MTV_ID = GetRecordType_MTV_ID from [POMS_DB].[dbo].[F_Get_OrderAccess_By_GUID] (@ORDER_CODE_GUID ,@ORDER_ID ,@UserName ,@UserType_MTV_CODE ,@GetRecordType_MTV_ID)

END
GO
