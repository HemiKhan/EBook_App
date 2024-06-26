USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_OrderDetail_ClientIdentifier_By_GUID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_OrderDetail_ClientIdentifier_By_GUID] 'D0ACF846-16B2-43B8-9CB4-7BD8013D558F',0,'ABDULLAH.ARSHAD',2,null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_OrderDetail_ClientIdentifier_By_GUID]
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
,[Code] nvarchar(20)
,[Name] nvarchar(50)
,[Value] nvarchar(250)
,[IsRequired] bit
,[IsDuplicateAllowed] bit
,[IsModifyAllowed] bit
,[IsHidden] bit
)

if @GetRecordType_MTV_ID = 147100
begin
	insert into @ReturnTable ([OrderID], [Code] ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden])
	select ORDER_ID, CODE ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden]
	from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_ClientIdentifier_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147101,147102)
begin
	insert into @ReturnTable ([OrderID], [Code] ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden])
	select ORDER_ID, CODE ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden]
	from [POMS_DB].[dbo].[F_Get_POMSArchive_OrderDetail_ClientIdentifier_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID = 147103
begin
	insert into @ReturnTable ([OrderID], [Code] ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden])
	select ORDER_ID, CODE ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden]
	from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_ClientIdentifier_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147104,147105)
begin
	insert into @ReturnTable ([OrderID], [Code] ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden])
	select ORDER_ID, CODE ,[Name] ,[Value] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden]
	from [POMS_DB].[dbo].[F_Get_PinnacleProdArchive_OrderDetail_ClientIdentifier_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end

if not exists(select * from @ReturnTable) and @ReturnText = ''
begin
	set @ReturnText = 'No Record Found'
end
else
begin
	set @ReturnCode = 1
end

select * from @ReturnTable order by [Name]

END
GO
