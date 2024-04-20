USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_OrderDetail_Assignment_By_GUID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_OrderDetail_Assignment_By_GUID] '7ECADB58-AC2A-4535-BECE-40B1441999F5',0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147103,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_OrderDetail_Assignment_By_GUID]
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
)

AS

BEGIN

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
, [CurrentAssignToDeptMTVCode] nvarchar(20)
, [CurrentAssignToDeptName] nvarchar(50)
, [OEDAssignTo] nvarchar(150)
, [OEDAssignToDateTime] datetime
--, [OEDStatus_MTV_ID] int
, [OEDStatusName] nvarchar(50)
, [OEDStatusDateTime] datetime
, [OEDCompletedDateTime] datetime
, [OEDFollowUpDateTime] datetime
, [OEDFollowUPCount] int
, [CSRAssignTo] nvarchar(150)
, [CSRAssignToDateTime] datetime
--, [CSRStatus_MTV_ID] int
, [CSRStatusName] nvarchar(50)
, [CSRStatusDateTime] datetime
, [CSRCompletedDateTime] datetime
, [CSRFollowUpDateTime] datetime
, [CSRFollowUpCount] int
, [DispatchAssignTo] nvarchar(150)
, [DispatchAssignToDateTime] datetime
--, [DispatchStatus_MTV_ID] int
, [DispatchStatusName] nvarchar(50)
, [DispatchStatusDateTime] datetime
, [DispatchCompletedDateTime] datetime
, [DispatchFollowUpDateTime] datetime
, [DispatchFollowUpCount] int
, [AccountAssignTo] nvarchar(150)
, [AccountAssignToDateTime] datetime
--, [AccountStatus_MTV_ID] int
, [AccountStatusName] nvarchar(50)
, [AccountStatusDateTime] datetime
, [AccountCompletedDateTime] datetime
, [AccountFollowUpDateTime] datetime
, [AccountFollowUpCount] int

)

if @GetRecordType_MTV_ID = 147100
begin
	insert into @ReturnTable
	select ORDER_ID
	,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,OEDAssignTo
	,OEDAssignToDateTime
	--,OEDStatus_MTV_ID
	,OEDStatus_Name
	,OEDStatusDateTime
	,OEDCompletedDateTime
	,OEDFollowUpDateTime
	,OEDFollowUPCount
	,CSRAssignTo
	,CSRAssignToDateTime
	--,CSRStatus_MTV_ID
	,CSRStatus_Name
	,CSRStatusDateTime
	,CSRCompletedDateTime
	,CSRFollowUpDateTime
	,CSRFollowUpCount
	,DispatchAssignTo
	,DispatchAssignToDateTime
	--,DispatchStatus_MTV_ID
	,DispatchStatus_Name
	,DispatchStatusDateTime
	,DispatchCompletedDateTime
	,DispatchFollowUpDateTime
	,DispatchFollowUpCount
	,AccountAssignTo
	,AccountAssignToDateTime
	--,AccountStatus_MTV_ID
	,AccountStatus_Name
	,AccountStatusDateTime
	,AccountCompletedDateTime
	,AccountFollowUpDateTime
	,AccountFollowUpCount
	from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_Assignment_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147101,147102)
begin
	insert into @ReturnTable
	select ORDER_ID
	,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,OEDAssignTo
	,OEDAssignToDateTime
	--,OEDStatus_MTV_ID
	,OEDStatus_Name
	,OEDStatusDateTime
	,OEDCompletedDateTime
	,OEDFollowUpDateTime
	,OEDFollowUPCount
	,CSRAssignTo
	,CSRAssignToDateTime
	--,CSRStatus_MTV_ID
	,CSRStatus_Name
	,CSRStatusDateTime
	,CSRCompletedDateTime
	,CSRFollowUpDateTime
	,CSRFollowUpCount
	,DispatchAssignTo
	,DispatchAssignToDateTime
	--,DispatchStatus_MTV_ID
	,DispatchStatus_Name
	,DispatchStatusDateTime
	,DispatchCompletedDateTime
	,DispatchFollowUpDateTime
	,DispatchFollowUpCount
	,AccountAssignTo
	,AccountAssignToDateTime
	--,AccountStatus_MTV_ID
	,AccountStatus_Name
	,AccountStatusDateTime
	,AccountCompletedDateTime
	,AccountFollowUpDateTime
	,AccountFollowUpCount
	from [POMS_DB].[dbo].[F_Get_POMSArchive_OrderDetail_Assignment_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID = 147103
begin
	insert into @ReturnTable
	select ORDER_ID
	,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,OEDAssignTo
	,OEDAssignToDateTime
	--,OEDStatus_MTV_ID
	,OEDStatus_Name
	,OEDStatusDateTime
	,OEDCompletedDateTime
	,OEDFollowUpDateTime
	,OEDFollowUPCount
	,CSRAssignTo
	,CSRAssignToDateTime
	--,CSRStatus_MTV_ID
	,CSRStatus_Name
	,CSRStatusDateTime
	,CSRCompletedDateTime
	,CSRFollowUpDateTime
	,CSRFollowUpCount
	,DispatchAssignTo
	,DispatchAssignToDateTime
	--,DispatchStatus_MTV_ID
	,DispatchStatus_Name
	,DispatchStatusDateTime
	,DispatchCompletedDateTime
	,DispatchFollowUpDateTime
	,DispatchFollowUpCount
	,AccountAssignTo
	,AccountAssignToDateTime
	--,AccountStatus_MTV_ID
	,AccountStatus_Name
	,AccountStatusDateTime
	,AccountCompletedDateTime
	,AccountFollowUpDateTime
	,AccountFollowUpCount
	from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_Assignment_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147104,147105)
begin
	insert into @ReturnTable
	select ORDER_ID
	,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,OEDAssignTo
	,OEDAssignToDateTime
	--,OEDStatus_MTV_ID
	,OEDStatus_Name
	,OEDStatusDateTime
	,OEDCompletedDateTime
	,OEDFollowUpDateTime
	,OEDFollowUPCount
	,CSRAssignTo
	,CSRAssignToDateTime
	--,CSRStatus_MTV_ID
	,CSRStatus_Name
	,CSRStatusDateTime
	,CSRCompletedDateTime
	,CSRFollowUpDateTime
	,CSRFollowUpCount
	,DispatchAssignTo
	,DispatchAssignToDateTime
	--,DispatchStatus_MTV_ID
	,DispatchStatus_Name
	,DispatchStatusDateTime
	,DispatchCompletedDateTime
	,DispatchFollowUpDateTime
	,DispatchFollowUpCount
	,AccountAssignTo
	,AccountAssignToDateTime
	--,AccountStatus_MTV_ID
	,AccountStatus_Name
	,AccountStatusDateTime
	,AccountCompletedDateTime
	,AccountFollowUpDateTime
	,AccountFollowUpCount
	from [POMS_DB].[dbo].[F_Get_PinnacleProdArchive_OrderDetail_Assignment_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end

if not exists(select * from @ReturnTable) and @ReturnText = ''
begin
	set @ReturnText = 'No Record Found'
end
else
begin
	set @ReturnCode = 1
end

select * from @ReturnTable

END
GO
