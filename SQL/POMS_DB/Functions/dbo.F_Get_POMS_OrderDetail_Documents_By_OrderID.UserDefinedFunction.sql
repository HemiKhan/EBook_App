USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_Documents_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_Documents_By_OrderID] (10100656,0,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100,null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_Documents_By_OrderID]
(	
	@ORDER_ID int
	,@OD_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@IsDocument bit = null
)
RETURNS @ReturnTable table
([OrderID] int
, [OD_ID] int
, [DocumentType_MTV_ID] int
, [DocumentType_Name] nvarchar(50)
, [AttachmentType_MTV_ID] int
, [AttachmentType_Name] nvarchar(50)
, [ImageName] nvarchar(100)
, [Description_] nvarchar(250)
, [Path_] nvarchar(250)
, [RefNo] nvarchar(40)
, [RefNo2] nvarchar(40)
, [RefID] int
, [RefID2] int
, [IsPublic] bit
, [Location] nvarchar(20)
, [DRIVER_ID] int
, [DRIVER_NAME] nvarchar(50)
, [DeliveryORPickup_Name] nvarchar(250)
, [DeliveryORPickup_Date] datetime
, [ThumbnailGUID] nvarchar(50)
, [AddedBy] nvarchar(150)
, [AddedOn] datetime
, [ModifiedBy] nvarchar(150)
, [ModifiedOn] datetime
, TotalRecords int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	if @GetRecordType_MTV_ID in (147100,147102)
	begin
		select @TotalRecords = (@TotalRecords + count(odoc.[OD_ID])) from [POMS_DB].[dbo].[T_Order_Docs] odoc with (nolock)
		where odoc.ORDER_ID = @ORDER_ID and odoc.IsPublic = @IsPublic and odoc.IsActive = 1
		and (@IsDocument is null 
			or (@IsDocument is not null and @IsDocument = 1 and odoc.[DocumentType_MTV_ID] not in (111104,111105))
			or (@IsDocument is not null and @IsDocument = 0 and odoc.[DocumentType_MTV_ID] in (111104,111105)))
		and (@OD_ID = 0 or (odoc.[OD_ID] = @OD_ID and @OD_ID > 0))

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [OD_ID] , [DocumentType_MTV_ID] , [DocumentType_Name] , [AttachmentType_MTV_ID] , [AttachmentType_Name] , [ImageName] , [Description_] , [Path_] , [RefNo] , [RefNo2] , [RefID] , [RefID2] 
			, [IsPublic] , [Location] , [DRIVER_ID] , [DRIVER_NAME] , [DeliveryORPickup_Name] , [DeliveryORPickup_Date] , [ThumbnailGUID] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
			select [OrderID] = odoc.ORDER_ID
				, odoc.[OD_ID] 
				, odoc.[DocumentType_MTV_ID] 
				, [DocumentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odoc.[DocumentType_MTV_ID])
				, odoc.[AttachmentType_MTV_ID] 
				, [AttachmentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odoc.[AttachmentType_MTV_ID]) 
				, odoc.[ImageName] 
				, odoc.[Description_] 
				, odoc.[Path_] 
				, odoc.[RefNo] 
				, odoc.[RefNo2] 
				, odoc.[RefID] 
				, odoc.[RefID2] 
				, odoc.[IsPublic] 
				, odoc.[Location] 
				, odoc.[DRIVER_ID] 
				, [DRIVER_NAME] = [POMS_DB].[dbo].[F_Get_PinnacleDriverName_From_DriverID] (odoc.[DRIVER_ID])
				, odoc.[DeliveryORPickup_Name] 
				, odoc.[DeliveryORPickup_Date] 
				, [ThumbnailGUID] = odt.GUID_
				, [AddedBy] = afn.FullName
				, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odoc.[AddedOn],@TimeZone_ID,null,@TimeZoneName)
				, [ModifiedBy] = mfn.FullName
				, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odoc.[ModifiedOn],@TimeZone_ID,null,@TimeZoneName)
				, TotalRecords = @TotalRecords
			from [POMS_DB].[dbo].[T_Order_Docs] odoc with (nolock)
			left join [POMS_DB].[dbo].[T_Order_Docs_Thumbnail] odt with (nolock) on odoc.[OD_ID] = odt.[OD_ID] and odoc.IsActive = 1
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (odoc.[AddedBy]) afn
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (odoc.[ModifiedBy]) mfn
			where odoc.ORDER_ID = @ORDER_ID and odoc.IsPublic = @IsPublic and odoc.IsActive = 1
			and (@IsDocument is null 
				or (@IsDocument is not null and @IsDocument = 1 and odoc.[DocumentType_MTV_ID] not in (111104,111105))
				or (@IsDocument is not null and @IsDocument = 0 and odoc.[DocumentType_MTV_ID] in (111104,111105)))
			and (@OD_ID = 0 or (odoc.[OD_ID] = @OD_ID and @OD_ID > 0))
		end
	end
	if @GetRecordType_MTV_ID in (147102)
	begin
		Declare @TempTotalRecords int = 0
		select @TempTotalRecords = (@TempTotalRecords + count(odoc.[OD_ID])) from [POMSArchive_DB].[dbo].[T_Order_Docs] odoc with (nolock)
		where odoc.ORDER_ID = @ORDER_ID and odoc.IsPublic = @IsPublic and odoc.IsActive = 1
		and (@IsDocument is null 
			or (@IsDocument is not null and @IsDocument = 1 and odoc.[DocumentType_MTV_ID] not in (111104,111105))
			or (@IsDocument is not null and @IsDocument = 0 and odoc.[DocumentType_MTV_ID] in (111104,111105)))
		and (@OD_ID = 0 or (odoc.[OD_ID] = @OD_ID and @OD_ID > 0))

		if @TempTotalRecords > 0
		begin
			set @TotalRecords = @TotalRecords + @TempTotalRecords
			insert into @ReturnTable ([OrderID] , [OD_ID] , [DocumentType_MTV_ID] , [DocumentType_Name] , [AttachmentType_MTV_ID] , [AttachmentType_Name] , [ImageName] , [Description_] , [Path_] , [RefNo] , [RefNo2] , [RefID] , [RefID2] 
			, [IsPublic] , [Location] , [DRIVER_ID] , [DRIVER_NAME] , [DeliveryORPickup_Name] , [DeliveryORPickup_Date] , [ThumbnailGUID] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
			select [OrderID] = odoc.ORDER_ID
				, odoc.[OD_ID] 
				, odoc.[DocumentType_MTV_ID] 
				, [DocumentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odoc.[DocumentType_MTV_ID])
				, odoc.[AttachmentType_MTV_ID] 
				, [AttachmentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odoc.[AttachmentType_MTV_ID]) 
				, odoc.[ImageName] 
				, odoc.[Description_] 
				, odoc.[Path_] 
				, odoc.[RefNo] 
				, odoc.[RefNo2] 
				, odoc.[RefID] 
				, odoc.[RefID2] 
				, odoc.[IsPublic] 
				, odoc.[Location] 
				, odoc.[DRIVER_ID] 
				, [DRIVER_NAME] = [POMS_DB].[dbo].[F_Get_PinnacleDriverName_From_DriverID] (odoc.[DRIVER_ID])
				, odoc.[DeliveryORPickup_Name] 
				, odoc.[DeliveryORPickup_Date] 
				, [ThumbnailGUID] = odt.GUID_
				, [AddedBy] = afn.FullName
				, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odoc.[AddedOn],@TimeZone_ID,null,@TimeZoneName)
				, [ModifiedBy] = mfn.FullName
				, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odoc.[ModifiedOn],@TimeZone_ID,null,@TimeZoneName)
				, TotalRecords = @TotalRecords
			from [POMSArchive_DB].[dbo].[T_Order_Docs] odoc with (nolock)
			left join [POMS_DB].[dbo].[T_Order_Docs_Thumbnail] odt with (nolock) on odoc.[OD_ID] = odt.[OD_ID] and odoc.IsActive = 1
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (odoc.[AddedBy]) afn
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (odoc.[ModifiedBy]) mfn
			where odoc.ORDER_ID = @ORDER_ID and odoc.IsPublic = @IsPublic and odoc.IsActive = 1
			and (@IsDocument is null 
				or (@IsDocument is not null and @IsDocument = 1 and odoc.[DocumentType_MTV_ID] not in (111104,111105))
				or (@IsDocument is not null and @IsDocument = 0 and odoc.[DocumentType_MTV_ID] in (111104,111105)))
			and (@OD_ID = 0 or (odoc.[OD_ID] = @OD_ID and @OD_ID > 0))
		end
	end
	else if @GetRecordType_MTV_ID in (147101)
	begin
		select @TotalRecords = (@TotalRecords + count(odoc.[OD_ID])) from [POMSArchive_DB].[dbo].[T_Order_Docs] odoc with (nolock)
		where odoc.ORDER_ID = @ORDER_ID and odoc.IsPublic = @IsPublic and odoc.IsActive = 1
		and (@IsDocument is null 
			or (@IsDocument is not null and @IsDocument = 1 and odoc.[DocumentType_MTV_ID] not in (111104,111105))
			or (@IsDocument is not null and @IsDocument = 0 and odoc.[DocumentType_MTV_ID] in (111104,111105)))
		and (@OD_ID = 0 or (odoc.[OD_ID] = @OD_ID and @OD_ID > 0))

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [OD_ID] , [DocumentType_MTV_ID] , [DocumentType_Name] , [AttachmentType_MTV_ID] , [AttachmentType_Name] , [ImageName] , [Description_] , [Path_] , [RefNo] , [RefNo2] , [RefID] , [RefID2] 
			, [IsPublic] , [Location] , [DRIVER_ID] , [DRIVER_NAME] , [DeliveryORPickup_Name] , [DeliveryORPickup_Date] , [ThumbnailGUID] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
			select [OrderID] = odoc.ORDER_ID
				, odoc.[OD_ID] 
				, odoc.[DocumentType_MTV_ID] 
				, [DocumentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odoc.[DocumentType_MTV_ID])
				, odoc.[AttachmentType_MTV_ID] 
				, [AttachmentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odoc.[AttachmentType_MTV_ID]) 
				, odoc.[ImageName] 
				, odoc.[Description_] 
				, odoc.[Path_] 
				, odoc.[RefNo] 
				, odoc.[RefNo2] 
				, odoc.[RefID] 
				, odoc.[RefID2] 
				, odoc.[IsPublic] 
				, odoc.[Location] 
				, odoc.[DRIVER_ID] 
				, [DRIVER_NAME] = [POMS_DB].[dbo].[F_Get_PinnacleDriverName_From_DriverID] (odoc.[DRIVER_ID])
				, odoc.[DeliveryORPickup_Name] 
				, odoc.[DeliveryORPickup_Date] 
				, [ThumbnailGUID] = odt.GUID_
				, [AddedBy] = afn.FullName
				, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odoc.[AddedOn],@TimeZone_ID,null,@TimeZoneName)
				, [ModifiedBy] = mfn.FullName
				, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odoc.[ModifiedOn],@TimeZone_ID,null,@TimeZoneName)
				, TotalRecords = @TotalRecords
			from [POMSArchive_DB].[dbo].[T_Order_Docs] odoc with (nolock)
			left join [POMS_DB].[dbo].[T_Order_Docs_Thumbnail] odt with (nolock) on odoc.[OD_ID] = odt.[OD_ID] and odoc.IsActive = 1
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (odoc.[AddedBy]) afn
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (odoc.[ModifiedBy]) mfn
			where odoc.ORDER_ID = @ORDER_ID and odoc.IsPublic = @IsPublic and odoc.IsActive = 1
			and (@IsDocument is null 
				or (@IsDocument is not null and @IsDocument = 1 and odoc.[DocumentType_MTV_ID] not in (111104,111105))
				or (@IsDocument is not null and @IsDocument = 0 and odoc.[DocumentType_MTV_ID] in (111104,111105)))
			and (@OD_ID = 0 or (odoc.[OD_ID] = @OD_ID and @OD_ID > 0))
		end
	end

	return
	

end
GO
