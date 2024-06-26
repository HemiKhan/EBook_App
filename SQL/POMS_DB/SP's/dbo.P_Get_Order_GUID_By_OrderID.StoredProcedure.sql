USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Order_GUID_By_OrderID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_Order_GUID_By_OrderID] 99999999,'string','ABDULLAH.ARSHAD','METRO-USER',null,13,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_Order_GUID_By_OrderID]
(
	@ORDER_ID int
	,@TRACKING_NO nvarchar(40)
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(250) output
)

AS

BEGIN

set @UserName = upper(@UserName)
set @ReturnCode = 0
set @ReturnText = ''

set @ORDER_ID = isnull(@ORDER_ID,0)
set @TRACKING_NO = isnull(@TRACKING_NO,'')

Declare @ReturnTable table (Order_ID int
,Tracking_NO nvarchar(40)
,Order_Code_Guid nvarchar(36)
,GetRecordType_MTV_ID int)

if @ORDER_ID != 0 or @TRACKING_NO != ''
begin
	insert into @ReturnTable
	select Order_ID ,Tracking_NO ,Order_Code_Guid ,GetRecordType_MTV_ID
	from [POMS_DB].[dbo].[F_Get_Order_GUID_By_OrderID] ('', @ORDER_ID ,@TRACKING_NO ,@UserName ,@UserType_MTV_CODE ,@IsPublic ,@TimeZone_ID,1)
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

if not exists(select * from @ReturnTable)
begin
	set @ReturnText = (case when @TRACKING_NO != '' then 'Invalid Tracking No' else 'Invalid Order ID' end)
end
else
begin
	set @ReturnCode = 1
end

select * from @ReturnTable

END
GO
