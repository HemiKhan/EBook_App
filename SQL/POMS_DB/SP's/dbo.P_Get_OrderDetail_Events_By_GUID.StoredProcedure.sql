USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_OrderDetail_Events_By_GUID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' Declare @Ret_TotalRecords int = 0 exec [dbo].[P_Get_OrderDetail_Events_By_GUID] '7ECADB58-AC2A-4535-BECE-40B1441999F5',0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147103,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out,@TotalRecords=@Ret_TotalRecords out select @Ret_ReturnCode ,@Ret_ReturnText ,@Ret_TotalRecords
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_OrderDetail_Events_By_GUID]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(250) output
	,@TotalRecords int output
)

AS

BEGIN

set @TotalRecords = 0
set @ORDER_CODE_GUID = upper(@ORDER_CODE_GUID)
set @UserName = upper(@UserName)
set @ReturnCode = 0
set @ReturnText = ''

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
end
else
begin
	set @ReturnCode = 1
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

Declare @ReturnTable table
([OrderID] int
, [EL_ID] int
, [Activity] nvarchar(50)
, [Event] nvarchar(50)
, [Date] datetime
, [Trigger] nvarchar(50)
, [Location] nvarchar(50)
, [InitiatedBy] nvarchar(250)
, TotalRecords int
)

if @GetRecordType_MTV_ID in (147100,147101,147102)
begin
	insert into @ReturnTable
	select [OrderID] 
	, [EL_ID] 
	, [Activity] 
	, [Event] 
	, [Date] 
	, [Trigger] 
	, [Location] 
	, [InitiatedBy] 
	, TotalRecords
	from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_Events_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147103,147104,147105)
begin
	insert into @ReturnTable
	select [OrderID] 
	, [EL_ID] 
	, [Activity] 
	, [Event] 
	, [Date] 
	, [Trigger] 
	, [Location] 
	, [InitiatedBy] 
	, TotalRecords
	from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_Events_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end

select top 1 @TotalRecords = TotalRecords from @ReturnTable

--if not exists(select * from @ReturnTable) and @ReturnText = ''
--begin
--	set @ReturnText = 'No Record Found'
--end
--else
--begin
--	set @ReturnCode = 1
--end

select * from @ReturnTable order by [EL_ID] desc

END
GO
