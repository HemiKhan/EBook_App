USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Validate_Location]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================================================
-- Created by	: Abdullah
-- Date Created	: 09-22-2023
--
-- exec [POMS_DB].[dbo].[P_Validate_Location] 'OUT-IL', 10000, 'ABDULLAH.ARSHAD'
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[P_Validate_Location]
(
	@LocationID nvarchar(50)
	,@ScanType int
	,@UserName nvarchar(150)
)

AS

BEGIN
	
	set @ScanType = [POMS_DB].[dbo].[F_Get_PinnacleScanType_From_NewScanType] (@ScanType)

	set @LocationID = upper(@LocationID)
	set @UserName = upper(@UserName)
	Declare @HubCode nvarchar(20) = ''
	Declare @HubName nvarchar(50) = ''
	Declare @ReturnCode bit = 0
	Declare @ReturnText nvarchar(250) = ''

	--Declare @UserID int = 0
	--Declare @Partner bit = 0
	--select @UserID = [Web UserID] , @Partner = [Partner] from [PinnacleProd].[dbo].[Metropolitan$Web User Login] with (nolock) where Username = @UserName

	--select @UserID = isnull(@UserID,0) ,@Partner = isnull(@Partner,0)

	--if @UserID = 0
	--begin
	--	set @ReturnText = 'Invalid Username'
	--end

	if @ReturnText = ''
	begin
		select top 1 @HubCode = twh.Code, @HubName = twh.[Wharehouse Name] from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] wle with (nolock)
		inner join [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] twh with (nolock) on wle.[Warehouse ID] = twh.Code where upper(wle.[Code]) = @LocationID
		
		if (isnull(@HubCode,'') = '')
		begin
			select top 1 @HubCode = twh.Code, @HubName = twh.[Wharehouse Name], @LocationID = upper(wle.[Code]) from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] wle with (nolock)
			inner join [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] twh with (nolock) on wle.[Warehouse ID] = twh.Code where upper(wle.[Barcode]) = @LocationID
		end
	end

	if isnull(@HubCode,'') = ''
	begin
		set @ReturnText = 'Invalid Location ID'
	end

	if @ReturnText = ''
	begin
		set @ReturnCode = 1
	end

	select ReturnCode = @ReturnCode ,ReturnText = @ReturnText ,LocationID = @LocationID ,HubCode = @HubCode ,HubName = @HubName

END
GO
