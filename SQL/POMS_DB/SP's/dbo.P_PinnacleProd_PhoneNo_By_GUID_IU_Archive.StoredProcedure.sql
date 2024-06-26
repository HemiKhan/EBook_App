USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_PhoneNo_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_PhoneNo_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@IsOrigin bit
	,@Phone nvarchar(20)

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
	Declare @OldPhone nvarchar(250) = ''

	select @pReturnText=isnull(( Select Top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with(nolock) where mtv.[Master Type ID]=10080 And mtv.ID=[Order Status]),'')
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] with (nolock) where [No_] = @OrderNo

	if @pReturnText <> 'Active'
	begin
		set @pReturnText = 'Order Status is ' + @pReturnText
	end
	else
	begin
		set @pReturnText = ''
	end

	if @IsOrigin = 1 and @pReturnText = ''
	begin
		select @OldPhone = sh.[Ship-from Phone]	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) where sh.[No_] = @OrderNo

		if (@pReturnText = '')
		begin
			update [PinnacleProd].[dbo].[Metropolitan$Sales Header] set [Ship-from Phone] = @Phone ,[Modified On] = getutcdate() ,[ModifiedBy] = @UserName where [No_] = @OrderNo

			if (@OldPhone <> @Phone)
			begin
				exec [PinnacleProd].[dbo].[P_Update_Phones] @OrderNo
			end

			set @pReturnCode = 1
			
			if (@OldPhone <> @Phone)
				begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Phone,@OldPhone,'','Ship-from Phone','Metropolitan$Sales Header',@OrderNo,@UserName,40000,@OrderNo end
		end
	end
	else if @pReturnText = ''
	begin
		select @OldPhone = sh.[Ship-to Phone] from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) where sh.[No_] = @OrderNo

		if @pReturnText = ''
		begin

			update [PinnacleProd].[dbo].[Metropolitan$Sales Header] set [Ship-to Phone] = @Phone ,[Modified On] = getutcdate() ,[ModifiedBy] = @UserName where [No_] = @OrderNo

			if (@OldPhone <> @Phone)
			begin
				exec [PinnacleProd].[dbo].[P_Update_Phones] @OrderNo
			end

			set @pReturnCode = 1
			
			if (@OldPhone <> @Phone)
				begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Phone,@OldPhone,'','Ship-to Phone','Metropolitan$Sales Header',@OrderNo,@UserName,40000,@OrderNo end
			
		end
	end

	select	
	OrderID = sh.[No_]
	, Return_Code = @pReturnCode
	, Return_Text = @pReturnText
	, @OldPhone as OldPhone
	, (oldph.[FormattedPhoneNo] + oldph.[FormattedExtension]) as OldPhoneNoFormatted
	, [NewPhone] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Phone] else sh.[Ship-to Phone] end),'')
	, [NewPhoneNoFormatted] = (case when @IsOrigin = 1 then (oph.[FormattedPhoneNo] + oph.[FormattedExtension]) else (dph.[FormattedPhoneNo] + dph.[FormattedExtension]) end)	
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock)
	cross apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](@OldPhone) oldph
	cross apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-from Phone]) oph
	cross apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-to Phone]) dph
	where sh.[No_] = @OrderNo
END
GO
