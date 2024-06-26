USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Update_Manifest_Status]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ======================================================================================
-- Declare @RetReturnCode bit = 0 Declare @RetReturnText nvarchar(4000) = '' Declare @Ret_ConfirmationRequired bit = '' exec [POMS_DB].[dbo].[P_Update_Manifest_Status] 115101, 113101, 12345, 50000, 0, 'Test Comment', 'ABDULLAH.ARSHAD', -14400000, 13, @ConfirmationRequired = @Ret_ConfirmationRequired out ,@ReturnCode = @RetReturnCode out, @ReturnText = @RetReturnText out select @Ret_ConfirmationRequired, @RetReturnCode ,@RetReturnText
-- ======================================================================================

CREATE PROCEDURE [dbo].[P_Update_Manifest_Status]
(
	@ManifestSource int,
	@ScanType int,
	@ManifestID int,
	@Status int,
	@Confirmation bit,
	@Comment nvarchar(250),
	@UserName nvarchar(150),
	@WebUserID int,
	@Offset int = -14400000,
	@TimeZoneID int = 13,
	@ConfirmationRequired bit output,
	@ReturnCode bit output,
	@ReturnText nvarchar(4000) output
)

AS

BEGIN
	
	set @ReturnCode = 0
	set @ReturnText = ''
	set @ConfirmationRequired = 0
	set @UserName = upper(isnull(@UserName,''))

	select @ScanType=ScanType_MTV_ID,@ManifestSource=ManifestType_MTV_ID
	from [POMS_DB].[dbo].[F_Get_New_ScanType_And_ManifestType_By_ScanType_And_ManifestType] (@ScanType,@ManifestSource)
	
	set @ScanType = [POMS_DB].[dbo].[F_Get_PinnacleScanType_From_NewScanType] (@ScanType)
	
	Declare @ManifestSubType int = 10000
	select @ManifestSource = PinnacleManifestType, @ManifestSubType = PinnacleManifestSubType 
	from [POMS_DB].[dbo].[F_Get_PinnacleManifestType_From_NewManifestType] (@ManifestSource)
	print @ManifestSource
	print @ManifestSubType

	--set @ConfirmationRequired = 1
	--set @ReturnText = 'Test1; Test2; Test3 asfa'
	--return

	if (isnull(@WebUserID,0) = 0)
	begin
		select @WebUserID = u.[USER_ID] from [POMS_DB].[dbo].[T_Users] u with (nolock) where u.USERNAME = @UserName
		set @WebUserID = isnull(@WebUserID,0)
	end

	if @WebUserID = 0 and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid Username'
		return;
	end

	if @ManifestSource not in (10000,30000,40000) and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid ManifestSource'
		return;
	end

	if @ManifestSource in (10000/*,20000,30000*/) and @ReturnText = ''
	begin
		Declare @OldStatus int = 0
		Declare @OldManifestSource int = 0

		select top 1 @OldStatus = m.[Status], @OldManifestSource = m.[Type] from [PinnacleProd].[dbo].[Metropolitan$Manifest] m with (nolock) where	m.[Entry No] = @ManifestID

		if (@OldManifestSource is null)
		begin
			set @ReturnText = 'Invalid Manifest No'
			return;
		end
		
		if (@OldStatus = @Status)
		begin
			set @ReturnText = 'Manifest Unloading Already Completed.'
			return;
		end
		
		update m
			set m.[Date Published] = case when @Status = 30000 then  Getutcdate() else m.[Date Published] end
			, m.[Date Completed] = case when @Status = 50000 then Getutcdate() else m.[Date Completed] end
			, m.[Last Status Changed On] = Getutcdate()
			, m.[Status] = @Status
		from [PinnacleProd].[dbo].[Metropolitan$Manifest] m where m.[Entry No] = @ManifestID

		insert into [PinnacleProd].[dbo].[Metropolitan$Manifest Comment] ([Comment], [Active Status], [Added By], [Date Added], [Date Modified], [Manifest ID]
		, [Manifest Group ID] , [Status], [Type], [Image ID], [Stop Exception Type], [Comment Source], [Stop Status], [Modified By])
		values (@Comment, 1, @WebUserID, GETUTCDATE(), GETUTCDATE(), @ManifestID, 0, @Status, 1, '', 0, 20000, 0, 0)

		-- Save OS&D report if completing LH manifest ...
		if (@Status = 50000 and @ManifestSource = 10000)
		begin
			exec [PinnacleProd].[dbo].[Metro_OSnD_SaveReportData] @ManifestID, @ManifestSource, @OldManifestSource, @WebUserID
		end

		insert into [PinnacleProd].[dbo].[Metropolitan$Comment] ([Comments], [GroupID], [Type], [ManifestID], [Stop Status], [AddedBy], [AddedOn])
		values (@Comment, '', 1, @ManifestID, 0, @WebUserID, Getutcdate())

		set @ReturnCode = 1
		set @ReturnText = 'Updated'
		return;

	end
	else if @ManifestSource in (30000) and @ReturnText = ''
	begin
		set @ReturnText = 'Disabled'
		return

		--exec [PPlus_DB].[dbo].[P_Manifest_Scann_Complete] @ManifestID, @WebUserID, @Msg = @ReturnText out
		--if (right(@ReturnText,13) = 'successfully.')
		--begin
		--	set @ReturnText = 'Updated'
		--end
		---- Save OS&D report if completing pickup manifest ...
		--exec [PinnacleProd].[dbo].[Metro_OSnD_SaveReportData] @ManifestID, 20000, @ManifestSource, @WebUserID
	end
	else if @ManifestSource in (40000) and @ReturnText = ''
	begin
		exec [PPlus_DB].[dbo].[P_Manifest_Scann_Complete] @ManifestID, @WebUserID, @Msg = @ReturnText out
		if (right(@ReturnText,13) = 'successfully.')
		begin
			set @ReturnText = 'Updated'
		end
		-- Save OS&D report if completing pickup manifest ...
		exec [PinnacleProd].[dbo].[Metro_OSnD_SaveReportData] @ManifestID, 20000, @ManifestSource, @WebUserID
	end

	
END
GO
