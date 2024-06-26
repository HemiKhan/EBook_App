USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ArchiveDetail_By_OrderID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_ArchiveDetail_By_OrderID] '81476343-24DE-48B6-B53F-FDFDB66BC616',0,'ABDULLAH.ARSHAD',2,null,13,0,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_ArchiveDetail_By_OrderID]
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

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

Declare @ReturnTable table
([ORDER_ID] int
, [Order_ArchiveDate] date
, [Order_Detail_ArchiveDate] date
, [Order_Additional_Info_ArchiveDate] date
, [Order_Items_ArchiveDate] date
, [Order_Items_Additional_Info_ArchiveDate] date
, [Order_Access_Log_ArchiveDate] date
, [Order_Audit_History_ArchiveDate] date
, [Order_Client_Identifier_ArchiveDate] date
, [Order_Comments_ArchiveDate] date
, [Order_Docs_ArchiveDate] date
, [Order_Events_ArchiveDate] date
, [Order_Events_List_ArchiveDate] date
, [Order_Item_Scans_ArchiveDate] date
, [Order_Related_Tickets_ArchiveDate] date
, [Order_Special_Instruction_ArchiveDate] date
, [Order_Special_Service_ArchiveDate] date
)

if @GetRecordType_MTV_ID in (147100,147101,147102)
begin
	insert into @ReturnTable
	select [ORDER_ID] int
	, [Order_ArchiveDate] date
	, [Order_Detail_ArchiveDate] date
	, [Order_Additional_Info_ArchiveDate] date
	, [Order_Items_ArchiveDate] date
	, [Order_Items_Additional_Info_ArchiveDate] date
	, [Order_Access_Log_ArchiveDate] date
	, [Order_Audit_History_ArchiveDate] date
	, [Order_Client_Identifier_ArchiveDate] date
	, [Order_Comments_ArchiveDate] date
	, [Order_Docs_ArchiveDate] date
	, [Order_Events_ArchiveDate] date
	, [Order_Events_List_ArchiveDate] date
	, [Order_Item_Scans_ArchiveDate] date
	, [Order_Related_Tickets_ArchiveDate] date
	, [Order_Special_Instruction_ArchiveDate] date
	, [Order_Special_Service_ArchiveDate]
	from [POMS_DB].[dbo].[F_Get_POMS_ArchiveDetail_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147103,147104,147105)
begin
	insert into @ReturnTable
	select [ORDER_ID] int
	, [Order_ArchiveDate] date
	, [Order_Detail_ArchiveDate] date
	, [Order_Additional_Info_ArchiveDate] date
	, [Order_Items_ArchiveDate] date
	, [Order_Items_Additional_Info_ArchiveDate] date
	, [Order_Access_Log_ArchiveDate] date
	, [Order_Audit_History_ArchiveDate] date
	, [Order_Client_Identifier_ArchiveDate] date
	, [Order_Comments_ArchiveDate] date
	, [Order_Docs_ArchiveDate] date
	, [Order_Events_ArchiveDate] date
	, [Order_Events_List_ArchiveDate] date
	, [Order_Item_Scans_ArchiveDate] date
	, [Order_Related_Tickets_ArchiveDate] date
	, [Order_Special_Instruction_ArchiveDate] date
	, [Order_Special_Service_ArchiveDate]
	from [POMS_DB].[dbo].[F_Get_PinnacleProd_ArchiveDetail_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
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
