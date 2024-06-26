USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Comment_By_GUID_IU]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ===============================================================
 Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' 
 exec [dbo].[P_Comment_By_GUID_IU] '',10100168,0,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
=============================================================== */

CREATE PROCEDURE [dbo].[P_Comment_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@pOC_ID int = 0
	,@pComment nvarchar(1000)
	,@pIsPublic bit = 0
	,@pIsCall bit = 0
	,@pIsActive bit = 1
	,@pImportanceLevel_MTV_ID int = null

	,@Source_MTV_ID int
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

Declare @ReturnTable table
(Return_Code bit
,Return_Text nvarchar(250)
,callsattempted int
,publiccommentcount int
,privatecommentcount int
)

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
	select * from @ReturnTable
	return
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

if @GetRecordType_MTV_ID in (147100,147101,147102)
begin
	Declare @Ret_AddRowCount int = 0
	Declare @Ret_EditRowCount int = 0
	Declare @Ret_DeleteRowCount int = 0
	Declare @Ret_Return_Code bit = 0
	Declare @Ret_Return_Text nvarchar(1000) = ''
	Declare @Ret_Execution_Error nvarchar(1000) = ''
	Declare @Ret_Error_Text nvarchar(max) = ''

	exec [POMS_DB].[dbo].[P_Order_Comments_IU] @pJson = '' ,@pOrder_ID = @ORDER_ID ,@pOC_ID = @pOC_ID ,@pComment = @pComment ,@pIsPublic = @pIsPublic ,@pUserName = @UserName 
	,@pIsCall = @pIsCall ,@pIsActive = @pIsActive ,@pImportanceLevel_MTV_ID = @pImportanceLevel_MTV_ID ,@pAddRowCount = @Ret_AddRowCount out ,@pEditRowCount = @Ret_EditRowCount out ,@pDeleteRowCount = @Ret_DeleteRowCount out 
	,@pReturn_Code = @Ret_Return_Code out ,@pReturn_Text = @Ret_Return_Text out ,@pExecution_Error = @Ret_Execution_Error out ,@pError_Text = @Ret_Error_Text out ,@pIsBeginTransaction = 0	,@pSource_MTV_ID = @Source_MTV_ID

end

END
GO
