USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Assignment_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_Assignment_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@pAssignTo as nvarchar(150)
	,@pAssignToStatus as int
	,@pDepartmentID as int
	,@pIsUpdateAssignToDepartment bit
	,@pComment nvarchar(1000)
	,@pIsPublicComment bit

	,@Source_MTV_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@pReturnCode bit output
	,@pReturnText nvarchar(250) output
AS
BEGIN
	
	SET @pReturnCode = 0

	Declare @OrderNo nvarchar(20) = cast(@ORDER_ID as nvarchar(20))	
	Declare @OldAssignTo nvarchar(150) = ''
	Declare @OldAssignToStatus INT
	Declare @OldAssignToStatusText nvarchar(150) = ''
	Declare @NewAssignToStatusText nvarchar(150) = ''
	Declare @OldDepartmentID INT
	Declare @OldCurrentDepartment nvarchar(150) = ''
	Declare @NewCurrentDepartment nvarchar(150) = ''	
	Declare @PPDepartmentID INT
	DECLARE @utcdate datetime = GETUTCDATE()
	DECLARE @Status int
	DECLARE @Offset int = -14400000

	Declare @Ret_Comment table
	(
		CReturn_Code bit
		,Ccallsattempted int
		,Cpubliccommentcount int
		,Cprivatecommentcount int
	);

	IF(@pAssignTo = null)
	BEGIN SET @pAssignTo = '' END	
		
	IF(@pDepartmentID = null)
	BEGIN SET @pDepartmentID = 0 END

	IF @pDepartmentID = 2 
	BEGIN 
		SET @PPDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](2)
	END
	ELSE IF @pDepartmentID = 3 
	BEGIN 
		SET @PPDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](3)
	END
	ELSE IF @pDepartmentID = 4 
	BEGIN 
		SET @PPDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](4)
	END
	ELSE IF @pDepartmentID = 5 
	BEGIN 
		SET @PPDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](5)
	END
	ELSE BEGIN SET @PPDepartmentID = 0 END

	IF(@PPDepartmentID = 10000)
	BEGIN
		SELECT @OldAssignTo = SL.[OED Assign To], @OldDepartmentID = SL.[Current Assigned Dept_]
		, @OldAssignToStatus = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10030 and mtv.[ID] = SL.[OED Status]),'')
		from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL with(nolock) where SL.[Document No]=@OrderNo
		
		--SET @OldAssignTo=ISNULL(@OldAssignTo,'')
			
		Select @Status = isnull([ID],0), @NewAssignToStatusText = isnull([Description],'') from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] with(nolock) where [Master Type ID]=10030 and ID = @pAssignToStatus

		Update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [OED Assign To] = @pAssignTo, [OED Assign Date] = @utcdate,	[OED Status]= @Status
		where [Document No] = @OrderNo and [Document Type]=1
			
		set @pReturnText = 'OED User is Assigned'
			
		if @OldAssignTo <> @pAssignTo
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @pAssignTo,@OldAssignTo,'','OED Assign To','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		if @OldAssignToStatusText <> @NewAssignToStatusText
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewAssignToStatusText,@OldAssignToStatusText,'','OED Status','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		set @pReturnCode = 1
	END
	ELSE IF(@PPDepartmentID = 20000)
	BEGIN
		SELECT @OldAssignTo = SL.[CSR Assign To], @OldDepartmentID = SL.[Current Assigned Dept_]
		, @OldAssignToStatus = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10030 and mtv.[ID] = SL.[CSR Status]),'')
		from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL with(nolock) where SL.[Document No]=@OrderNo
		
		--SET @OldAssignTo=ISNULL(@OldAssignTo,'')
			
		Select @Status = isnull([ID],0), @NewAssignToStatusText = isnull([Description],'') from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] with(nolock) where [Master Type ID]=10030 and ID = @pAssignToStatus

		Update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [CSR Assign To] = @pAssignTo, [CSR Assign Date] = @utcdate,	[CSR Status]= @Status
		where [Document No] = @OrderNo and [Document Type]=1
			
		set @pReturnText = 'CSR User is Assigned'
			
		if @OldAssignTo <> @pAssignTo
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @pAssignTo,@OldAssignTo,'','CSR Assign To','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		if @OldAssignToStatusText <> @NewAssignToStatusText
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewAssignToStatusText,@OldAssignToStatusText,'','CSR Status','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		set @pReturnCode = 1	
	END
	ELSE IF(@PPDepartmentID = 30000)
	BEGIN
		SELECT @OldAssignTo = SL.[Disptach Assign To], @OldDepartmentID = SL.[Current Assigned Dept_]
		, @OldAssignToStatus = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10030 and mtv.[ID] = SL.[Dispatch Status]),'')
		from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL with(nolock) where SL.[Document No]=@OrderNo
		
		--SET @OldAssignTo=ISNULL(@OldAssignTo,'')
			
		Select @Status = isnull([ID],0), @NewAssignToStatusText = isnull([Description],'') from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] with(nolock) where [Master Type ID]=10030 and ID = @pAssignToStatus

		Update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Disptach Assign To] = @pAssignTo, [Dispatch Assign Date] = @utcdate, [Dispatch Status]= @Status
		where [Document No] = @OrderNo and [Document Type]=1
			
		set @pReturnText = 'Dispatch User is Assigned'
			
		if @OldAssignTo <> @pAssignTo
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @pAssignTo,@OldAssignTo,'','Disptach Assign To','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		if @OldAssignToStatusText <> @NewAssignToStatusText
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewAssignToStatusText,@OldAssignToStatusText,'','Disptach Status','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		set @pReturnCode = 1	
	END
	ELSE IF(@PPDepartmentID = 40000)
	BEGIN
		SELECT @OldAssignTo = SL.[Accounting Assign To], @OldDepartmentID = SL.[Current Assigned Dept_]
		, @OldAssignToStatus = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10030 and mtv.[ID] = SL.[Accounting Status]),'')
		from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL with(nolock) where SL.[Document No]=@OrderNo
		
		--SET @OldAssignTo=ISNULL(@OldAssignTo,'')
			
		Select @Status = isnull([ID],0), @NewAssignToStatusText = isnull([Description],'') from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] with(nolock) where [Master Type ID]=10030 and ID = @pAssignToStatus

		Update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Accounting Assign To] = @pAssignTo, [Accounting Assign Date] = @utcdate, [Accounting Status]= @Status
		where [Document No] = @OrderNo and [Document Type]=1
			
		set @pReturnText = 'Accounting User is Assigned'
			
		if @OldAssignTo <> @pAssignTo
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @pAssignTo,@OldAssignTo,'','Accounting Assign To','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		if @OldAssignToStatusText <> @NewAssignToStatusText
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewAssignToStatusText,@OldAssignToStatusText,'','Accounting Status','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		set @pReturnCode = 1
	END

	set @OldCurrentDepartment = (Case 
	when @OldDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](2) then 'OED'
	when @OldDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](3) then 'CSR'
	when @OldDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](4) then 'Dispatch'
	when @OldDepartmentID = [POMS_DB].[dbo].[F_Get_PinnacleProd_DepartmentID](5) then 'Accounting'
	else '' end)
	
	set @NewCurrentDepartment = (Case 
	when @PPDepartmentID = 10000 then 'OED'
	when @PPDepartmentID = 20000 then 'CSR'
	when @PPDepartmentID = 30000 then 'Dispatch'
	when @PPDepartmentID = 40000 then 'Accounting'
	else '' end)

	if @pIsUpdateAssignToDepartment = 1
	begin
		Update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Current Assigned Dept_]=@PPDepartmentID,[Current Assigned User]=@pAssignTo where [Document No] = @OrderNo and [Document Type]=1
		set @pReturnCode = 1
		set @pReturnText = @pReturnText + ' And Department is Changed To ' + @NewCurrentDepartment

		if @OldCurrentDepartment <> @NewCurrentDepartment
		begin
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @NewCurrentDepartment,@OldCurrentDepartment,'','Current Assigned Dept_','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
	end

	if len(@pComment) > 0
	begin
		insert into @Ret_Comment (CReturn_Code ,Ccallsattempted ,Cpubliccommentcount ,Cprivatecommentcount)
		exec [PinnacleProd].[dbo].[P_Comment_By_GUID_IU] @OrderNo ,0 ,@pComment ,@UserType_MTV_CODE ,@pIsPublicComment ,1, @UserName ,@Source_MTV_ID ,0 ,@IsPublic 
	end

select	
[OrderID] = sl.[Document No]
,[AssignTo] = isnull((select top 1 wul.[FullName] from [PinnacleProd].[dbo].[vw_Metro_WebUsers] wul with (nolock) where wul.[Username] = 
(case when @PPDepartmentID = 10000 then sl.[OED Assign To]
when @PPDepartmentID = 20000 then sl.[CSR Assign To]
when @PPDepartmentID = 30000 then sl.[Disptach Assign To]
when @PPDepartmentID = 40000 then sl.[Accounting Assign To]
else '' end)
), '')

,[AssignToDepartment] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10020 and mtv.[ID] = @PPDepartmentID), '')

,[AssignDate] = (case when @PPDepartmentID = 10000 then (case when year(sl.[OED Assign Date]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[OED Assign Date],@TimeZone_ID,@Offset) end)
when @PPDepartmentID = 20000 then (case when year(sl.[CSR Assign Date]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[CSR Assign Date],@TimeZone_ID,@Offset) end)
when @PPDepartmentID = 30000 then (case when year(sl.[Dispatch Assign Date]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[Dispatch Assign Date],@TimeZone_ID,@Offset) end)
when @PPDepartmentID = 40000 then (case when year(sl.[Accounting Assign Date]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[Accounting Assign Date],@TimeZone_ID,@Offset) end)
else '' end)

--,[AssignStatus] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = @MTV_ID and mtv.[ID] = 
--(case when @PPDepartmentID = 10000 then sl.[OED Status]
--when @PPDepartmentID = 20000 then sl.[CSR Status]
--when @PPDepartmentID = 30000 then sl.[Dispatch Status]
--when @PPDepartmentID = 40000 then sl.[Accounting Status]
--else '' end)
--), '')

,[AssignCompletedOn] = (case when @PPDepartmentID = 10000 then (case when year(sl.[OED Completed On]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[OED Completed On],@TimeZone_ID,@Offset) end)
when @PPDepartmentID = 20000 then (case when year(sl.[CSR Completed On]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[CSR Completed On],@TimeZone_ID,@Offset) end)
when @PPDepartmentID = 30000 then (case when year(sl.[Dispatch Completed On]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[Dispatch Completed On],@TimeZone_ID,@Offset) end)
when @PPDepartmentID = 40000 then (case when year(sl.[Accounting Completed On]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[Accounting Completed On],@TimeZone_ID,@Offset) end)
else '' end)

,[CSRFollowupCall] = isnull(sl.[CSR Follow Up Call],0)

,[CurrentAssignTo]=sl.[Current Assigned User]
,[CurrentAssignToName]=isnull((select top 1 wul.[FullName] from [PinnacleProd].[dbo].[vw_Metro_WebUsers] wul with (nolock) where wul.[Username] = sl.[Current Assigned User]), '')
,[CurrentAssignToDepartment] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10020 and mtv.[ID] = sl.[Current Assigned Dept_]), '')
,[CurrentAssignToDepartmentID]=sl.[Current Assigned Dept_]

,Return_Code = @pReturnCode
,Return_Text = isnull((case when @pReturnCode = 1 then '' else @pReturnText end),'')

,CReturn_Code = isnull((select CReturn_Code from @Ret_Comment),0)
,Ccallsattempted = isnull((select Ccallsattempted from @Ret_Comment),0)
,Cprivatecommentcount = isnull((select Cprivatecommentcount from @Ret_Comment),0)
,Cpubliccommentcount = isnull((select Cpubliccommentcount from @Ret_Comment),0)

from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock)
where sl.[Document No] = @OrderNo

END
GO
