USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Comment_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_Comment_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@CommentID int
	,@Comment nvarchar(250)
	,@ActiveStatus bit 
	,@IsCall bit

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
	
set @pReturnCode = 0
Declare @OrderNo nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
set @UserName = upper(@UserName)
Declare @StartDate datetime = getutcdate()

if (@OrderNo <> '')
begin
	Declare @OldComment nvarchar(1000) = ''
	Declare @IsPublicText nvarchar(10) = ''
	Declare @IsOldPublicText nvarchar(10) = ''
	Declare @IsCallText nvarchar(10) = ''
	Declare @IsOldCallText nvarchar(10) = ''

	Set @IsPublicText = (case when @IsPublic = 1 then 'Public' else 'Private' end)
	Set @IsCallText = (case when @IsCall = 1 then 'True' else 'False' end)
	set @Comment = ltrim(rtrim(@Comment))

	if @CommentID > 0 and @ActiveStatus = 1
	begin
		if @Comment <> ''
		begin
			Select @OldComment = [Comment] 
			,@IsOldPublicText = (case when [IsPublic] = 1 then 'Public' else 'Private' end)
			,@IsOldCallText = (case when [Is Call] = 1 then 'True' else 'False' end)
			from [PinnacleProd].[dbo].[Metropolitan$Comments] with (nolock) where [ID] = @CommentID and [Order ID] = @OrderNo
		
			update [PinnacleProd].[dbo].[Metropolitan$Comments] set [Comment] = @Comment, [IsPublic] = @IsPublic, [Is Call] = @IsCall, [Modified On] = getutcdate(), [Modified By] = cast(@UserName as nvarchar(20)) where [ID] = @CommentID and [Order ID] = @OrderNo
			
			set @pReturnCode = 1
	
			if @OldComment <> @Comment
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Comment,@OldComment,'','Comment','Metropolitan$Comments',@OrderNo,@UserName,40000,@OrderNo
			end
			if @IsOldPublicText <> @IsPublicText
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @IsPublicText,@IsOldPublicText,'','IsPublic','Metropolitan$Comments',@OrderNo,@UserName,40000,@OrderNo
			end
			if @IsOldCallText <> @IsCallText
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @IsCallText,@IsOldCallText,'','IsCall','Metropolitan$Comments',@OrderNo,@UserName,40000,@OrderNo
			end
		end	
	end
	else if @CommentID > 0 and @ActiveStatus = 0
	begin
		Select @OldComment = [Comment] from [PinnacleProd].[dbo].[Metropolitan$Comments] with (nolock) where [ID] = @CommentID and [Order ID] = @OrderNo
		
		update [PinnacleProd].[dbo].[Metropolitan$Comments] set [Active Status] = @ActiveStatus, [Modified On] = getutcdate(), [Modified By] = cast(@UserName as nvarchar(20))
		, [Deleted By] = cast(@UserName as nvarchar(20)), [Deleted On] = getutcdate()  where [ID] = @CommentID and [Order ID] = @OrderNo
		
		set @pReturnCode = 1
		execute [dbo].[Metro_CheckAndAddAuditLog] @OldComment,'Delete','','Comment','Metropolitan$Comments',@OrderNo,@UserName,40000,@OrderNo
	end
	else if @OrderNo <> ''
	begin
		exec [PinnacleProd].[dbo].[Metro_AddOrderGeneralComment] @OrderNo,@Comment,@IsPublic,@UserName,40000,1,@IsCall
		set @pReturnCode = 1
	end
	
	insert [PPlus_DB].[dbo].[T_Order_Detail_SP_Record_Temp] ([SP_Name],[OrderNo],[StartDate_],[EndDate_])
	values ('P_Comment_By_GUID_IU',@OrderNo,@StartDate,getutcdate())

	Declare @callsattempted int = 0
	Declare @publiccommentcount int = 0
	Declare @privatecommentcount int = 0

	Select @callsattempted = sum((case when C.[Is Call] = 1 then 1 else 0 end))
		  ,@publiccommentcount = sum((case when C.[IsPublic] = 1 then 1 else 0 end))
		  ,@privatecommentcount = sum((case when C.[IsPublic] = 0 then 1 else 0 end))
	from [PinnacleProd].[dbo].[Metropolitan$Comments] C with (nolock) 
	where C.[Order ID] = @OrderNo and C.[Active Status] = 1
	group by C.[Order ID]

	--if @IsArchive = 1
	--begin
	--	Select @callsattempted = @callsattempted + (sum((case when C.[Is Call] = 1 then 1 else 0 end)))
	--	,@publiccommentcount = @publiccommentcount + (sum((case when C.[IsPublic] = 1 then 1 else 0 end)))
	--	,@privatecommentcount = @privatecommentcount + (sum((case when C.[IsPublic] = 0 then 1 else 0 end)))
	--	from [PinnacleArchiveDB].[dbo].[Metropolitan$Comments] C with (nolock) 
	--	where C.[Order ID] = @OrderID and C.[Active Status] = 1
	--	group by C.[Order ID]
	--end

	SELECT Return_Code = @pReturnCode
		  ,Return_Text = @pReturnText
		  ,callsattempted = @callsattempted  
		  ,publiccommentcount = @publiccommentcount
		  ,privatecommentcount = @privatecommentcount 
end
else
begin
	set @pReturnCode = 0
	set @pReturnText = 'Invalid Order'
end

END
GO
