USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Miles_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_Miles_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@Miles nvarchar(30)

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

Declare @OldMiles nvarchar(30) = ''

if (@OrderNo <> '')
begin

	select @OldMiles = [Estimated Miles] from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] with (nolock) where [Document No] = @OrderNo

	if (@OldMiles <> @Miles)
	begin
		update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup]	set [Estimated Miles] = @Miles where [Document No] = @OrderNo		
		set @pReturnCode = 1
		execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Miles,@OldMiles,'','Estimated Miles','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo		
	end

	SELECT  
		 Return_Code = @pReturnCode
		,Return_Text = @pReturnText
		,[estimatedmiles] = (case when IsNumeric(sl.[Estimated Miles]) = 1 then cast(sl.[Estimated Miles] as float) else 0 end)
	from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Document No] = @OrderNo
end
else
begin
	set @pReturnCode = 0
	set @pReturnText = 'Invalid Order'
end

END
GO
