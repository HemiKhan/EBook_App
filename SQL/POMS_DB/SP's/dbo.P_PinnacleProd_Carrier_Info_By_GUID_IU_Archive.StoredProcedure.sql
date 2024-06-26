USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Carrier_Info_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_Carrier_Info_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@pCarrierName nvarchar(50)
	,@pCarrierPro nvarchar(250)
	,@pCarrierTag nvarchar(50)
	,@pRef1 nvarchar(50)
	,@pRef2 nvarchar(50)

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

set @pCarrierName = ltrim(rtrim(@pCarrierName ))
set @pCarrierPro = ltrim(rtrim(@pCarrierPro ))
set @pCarrierTag = ltrim(rtrim(@pCarrierTag ))
set @pRef1 = ltrim(rtrim(@pRef1 ))
set @pRef2 = ltrim(rtrim(@pRef2 ))
Declare @OldCarrierName nvarchar(50) = ''
Declare @OldCarrierPro nvarchar(250) = ''
Declare @OldCarrierTag nvarchar(50) = ''
Declare @OldRef1 nvarchar(50) = ''
Declare @OldRef2 nvarchar(50) = ''
Declare @ClientID nvarchar(20) = ''
Declare @ClientName nvarchar(150) = ''
Declare @ExistsOrder nvarchar(20) = ''
Declare @ExistsOrderGUID nvarchar(36) = ''
Declare @SearchType nvarchar(max) = ''

if (@OrderNo <> '')
begin

	Select @ClientID = sh.[Bill-to Customer No_], @ClientName = c.[Name] 
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
	inner join [PinnacleProd].[dbo].[Metropolitan$Customer] c with (nolock)  on c.No_ = sh.[Bill-to Customer No_]
	where sh.No_ = @OrderNo

	select top 1 @ExistsOrder = isnull(sh.No_,''), @ExistsOrderGUID = od.GUID_
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
	inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sh.No_ = sl.[Document No]
	inner join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on sh.No_ = sl.[Document No]
	where sh.[Bill-to Customer No_] = @ClientID and sh.No_ <> @OrderNo and upper(ltrim(rtrim(sl.[Client Refrence #1]))) = upper(ltrim(rtrim(@pRef1)))
	
	if @ExistsOrder <> ''
	begin
		set @pReturnText = 'Unable to Update Order Because Client Ref1: ' + @pRef1 + ' Already Exist in Order # ' + '<a href="../order_detail.aspx?ID=' + @ExistsOrderGUID + '" target="_blank">' + @ExistsOrder + '</a>' + ' for Client ' + Upper(@ClientName)
	end

	if @pReturnText = ''
	begin
		select @OldCarrierName = [Carrier Name]
		,@OldCarrierPro = [Carrier PRO]
		,@OldCarrierTag = [Carrier Tag]
		,@OldRef1 = [Client Refrence #1]
		,@OldRef2 = [Client Refrence #2]
		from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] with (nolock) where [Document No] = @OrderNo

		if (@OldCarrierName <> @pCarrierName or @OldCarrierPro <> @pCarrierPro or @OldCarrierTag <> @pCarrierTag or @OldRef1 <> @pRef1 or @OldRef2 <> @pRef2)
		begin

			update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup]
			set [Carrier Name] = @pCarrierName ,[Carrier PRO] = @pCarrierPro ,[Carrier Tag] = @pCarrierTag ,[Client Refrence #1] = @pRef1 ,[Client Refrence #2] = @pRef2 
			where [Document No] = @OrderNo
			
			set @pReturnCode = 1

			if @OldCarrierName <> @pCarrierName
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@pCarrierName,@OldCarrierName,'','Carrier Name','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
			end
			
			if @OldCarrierPro <> @pCarrierPro
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@pCarrierPro,@OldCarrierPro,'','Carrier PRO','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
			end
			
			if @OldCarrierTag <> @pCarrierTag
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@pCarrierTag,@OldCarrierTag,'','Carrier Tag','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
			end
			
			if @OldRef1 <> @pRef1
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@pRef1,@OldRef1,'','Client Refrence #1','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
			end
			
			if @OldRef2 <> @pRef2
			begin
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@pRef2,@OldRef2,'','Client Refrence #2','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
			end
					
		end
	end

	if @pReturnCode = 1
	begin
		set @SearchType = (case when upper(@OldCarrierName) = upper(@pCarrierName) then @SearchType else (case when @SearchType = '' then 'CARRIER' else @SearchType + ',CARRIER' end) end) 
		set @SearchType = (case when upper(@OldCarrierPro) = upper(@pCarrierPro) then @SearchType else (case when @SearchType = '' then 'PRO' else @SearchType + ',PRO' end) end) 
		set @SearchType = (case when upper(@OldCarrierTag) = upper(@pCarrierTag) then @SearchType else (case when @SearchType = '' then 'TAG' else @SearchType + ',TAG' end) end) 
		set @SearchType = (case when upper(@OldRef1) = upper(@pRef1) then @SearchType else (case when @SearchType = '' then 'REF1' else @SearchType + ',REF1' end) end) 
		set @SearchType = (case when upper(@OldRef2) = upper(@pRef2) then @SearchType else (case when @SearchType = '' then 'REF2' else @SearchType + ',REF2' end) end) 	
		if (@SearchType <> '')
		begin
			exec [PinnacleProd].[dbo].[P_Orders_Search_Value_Character_IU] @OrderNo, @SearchType
		end
	end

	select 
		 Return_Code = @pReturnCode
		,Return_Text = @pReturnText
		,[carriername] = sl.[Carrier Name]
		,[carrierpro] = sl.[Carrier PRO]
		,[tag] = sl.[Carrier Tag]
		,[clientref1] = sl.[Client Refrence #1]
		,[clientref2] = sl.[Client Refrence #2]	
	from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Document No] = @OrderNo

end
else
begin
	set @pReturnCode = 0
	set @pReturnText = 'Invalid Order'
end

END
GO
