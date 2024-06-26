USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_Documents_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_Documents_By_OrderID] (3251522,0,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103,null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_Documents_By_OrderID]
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
	
	set @OD_ID = isnull(@OD_ID,0)
	Declare @TotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	if @GetRecordType_MTV_ID in (147103,147105)
	begin
		select @TotalRecords = (@TotalRecords + count(img.[Entry No])) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock)
		left join [PinnacleProd].[dbo].[Metropolitan$Proof of Delivery] POD with (nolock) on img.[Order No] = POD.[Order No] 
		and img.[Ref No_] = cast(POD.[Entry No] as nvarchar(20)) 
		--and img.[RefNoInt] = POD.[Entry No] and img.[RefNoInt] is not null 
		and img.[Master Type ID] = 10190 and POD.ActiveStatus = 1
		where img.[Order No] = @ORDER_NO and ((img.[Private] = 1 and @IsPublic = 0) or @IsPublic = 1) and img.IsActive = 1 and img.[Path] <> ''
		and ((img.[Master Type ID] = 10190 and POD.[Entry No] is not null) or (img.[Master Type ID] = 10110))
		and (@IsDocument is null 
			or (@IsDocument is not null and @IsDocument = 1 and POD.[Entry No] is null)
			or (@IsDocument is not null and @IsDocument = 0 and POD.[Entry No] is not null))
		and (@OD_ID = 0 or (img.[Entry No] = @OD_ID and @OD_ID > 0))

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [OD_ID] , [DocumentType_MTV_ID] , [DocumentType_Name] , [AttachmentType_MTV_ID] , [AttachmentType_Name] , [ImageName] , [Description_] , [Path_] , [RefNo] , [RefNo2] , [RefID] , [RefID2] 
			, [IsPublic] , [Location] , [DRIVER_ID] , [DRIVER_NAME] , [DeliveryORPickup_Name] , [DeliveryORPickup_Date] , [ThumbnailGUID] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
			select [OrderID] 
				, [OD_ID] 
				, [DocumentType_MTV_ID] 
				, [DocumentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[DocumentType_MTV_ID])
				, [AttachmentType_MTV_ID] 
				, [AttachmentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[AttachmentType_MTV_ID]) 
				, [ImageName] 
				, [Description_] 
				, [Path_] 
				, [RefNo] 
				, [RefNo2] 
				, [RefID] 
				, [RefID2] 
				, [IsPublic] 
				, [Location] 
				, [DRIVER_ID] 
				, [DRIVER_NAME] = [POMS_DB].[dbo].[F_Get_PinnacleDriverName_From_DriverID] (ilv.[DRIVER_ID])
				, [DeliveryORPickup_Name] 
				, [DeliveryORPickup_Date] 
				, [ThumbnailGUID] 
				, [AddedBy] = (case when [AddedByUserid] is not null then afni.FullName else afnn.FullName end)
				, [AddedOn] 
				, [ModifiedBy] = mfni.FullName
				, [ModifiedOn] 
				, TotalRecords
				from (
				select [OrderID] = @ORDER_ID
					, [OD_ID] = img.[Entry No]
					, [DocumentType_MTV_ID] = (case when POD.[Type] is null then
						(case when img.[Entity Type ID] = 10000 then 111100
							when img.[Entity Type ID] = 20000 then 111101
							when img.[Entity Type ID] = 30000 then 111102
							when img.[Entity Type ID] = 40000 then 111103
							when img.[Entity Type ID] = 50000 then 111106
							when img.[Entity Type ID] = 60000 then 111100
							else 0 end)
						when POD.[Type] = 1 then 111105
						when POD.[Type] = 2 then 111104
						else 0 end)
					, [AttachmentType_MTV_ID] = (case when img.[Source] = 0 then 128101
						when img.[Source] = 4 then 128102
						else 128100 end)
					, [ImageName] = img.[Image Name]
					, [Description_] = img.[Description]
					, [Path_] = img.[Path]
					, [RefNo] = img.[Ref No_]
					, [RefNo2] = null
					, [RefID] = img.[RefNoInt]
					, [RefID2] = null
					, [IsPublic] = (case when img.[Private] = 0 then 1 else 0 end) 
					, [Location] = (case when POD.[Type] is null then null else POD.[Received Location] end)
					, [DRIVER_ID] = (case when POD.[Type] is null then null else POD.[Delivery By] end)
					, [DeliveryORPickup_Name] = (case when POD.[Type] is null then null else POD.[Received By] end)
					, [DeliveryORPickup_Date] = (case when POD.[Type] is null then null else 
						(case when Year(POD.[Delivery On]) < 2000 then null else POD.[Delivery On] end)
						end)
					, [ThumbnailGUID] = it.GUID_ + it.FileExt
					, [AddedByUserid] = (case when POD.[Type] is not null then null else img.[Added By] end)
					, [AddedByUsername] = (case when POD.[Type] is null then null else img.[Added By] end)
					, [AddedBy] = null
					, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (img.[Added On],@TimeZone_ID,null,@TimeZoneName)
					, [ModifiedByUserid] = img.[Modify By]
					, [ModifiedBy] = null
					, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (img.[Modify On],@TimeZone_ID,null,@TimeZoneName)
					, TotalRecords = @TotalRecords
				from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock)
				left join [PinnacleProd].[dbo].[Metropolitan$Proof of Delivery] POD with (nolock) on img.[Order No] = POD.[Order No] 
				and img.[Ref No_] = cast(POD.[Entry No] as nvarchar(20)) 
				--and img.[RefNoInt] = POD.[Entry No] and img.[RefNoInt] is not null 
				and img.[Master Type ID] = 10190 and POD.ActiveStatus = 1
				left join [PinnacleProd].[dbo].[T_Image_Thumbnail] it with (nolock) on it.Image_Entry_No = img.[Entry No] and it.Is_Active = 1
				where img.[Order No] = @ORDER_NO and ((img.[Private] = 1 and @IsPublic = 0) or @IsPublic = 1) and img.IsActive = 1 and img.[Path] <> ''
				and ((img.[Master Type ID] = 10190 and POD.[Entry No] is not null) or (img.[Master Type ID] = 10110))
				and (@IsDocument is null 
					or (@IsDocument is not null and @IsDocument = 1 and POD.[Entry No] is null)
					or (@IsDocument is not null and @IsDocument = 0 and POD.[Entry No] is not null))
				and (@OD_ID = 0 or (img.[Entry No] = @OD_ID and @OD_ID > 0))
			) ilv outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ilv.[AddedByUserid]) afni
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ilv.[AddedByUsername]) afnn
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ilv.[ModifiedByUserid]) mfni
		end

		if @GetRecordType_MTV_ID in (147105)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(img.[Entry No])) from [PinnacleArchiveDB].[dbo].[Metropolitan$Image] img with (nolock)
			left join [PinnacleProd].[dbo].[Metropolitan$Proof of Delivery] POD with (nolock) on img.[Order No] = POD.[Order No] 
			and img.[Ref No_] = cast(POD.[Entry No] as nvarchar(20)) 
			--and img.[RefNoInt] = POD.[Entry No] and img.[RefNoInt] is not null 
			and img.[Master Type ID] = 10190 and POD.ActiveStatus = 1
			where img.[Order No] = @ORDER_NO and ((img.[Private] = 1 and @IsPublic = 0) or @IsPublic = 1) and img.IsActive = 1 and img.[Path] <> ''
			and ((img.[Master Type ID] = 10190 and POD.[Entry No] is not null) or (img.[Master Type ID] = 10010))
			and (@IsDocument is null 
				or (@IsDocument is not null and @IsDocument = 1 and POD.[Entry No] is null)
				or (@IsDocument is not null and @IsDocument = 0 and POD.[Entry No] is not null))
			and (@OD_ID = 0 or (img.[Entry No] = @OD_ID and @OD_ID > 0))

			if @TempTotalRecords > 0
			begin
				set @TempTotalRecords = @TempTotalRecords + @TotalRecords 
				insert into @ReturnTable ([OrderID] , [OD_ID] , [DocumentType_MTV_ID] , [DocumentType_Name] , [AttachmentType_MTV_ID] , [AttachmentType_Name] , [ImageName] , [Description_] , [Path_] , [RefNo] , [RefNo2] , [RefID] , [RefID2] 
				, [IsPublic] , [Location] , [DRIVER_ID] , [DRIVER_NAME] , [DeliveryORPickup_Name] , [DeliveryORPickup_Date] , [ThumbnailGUID] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
				select [OrderID] 
					, [OD_ID] 
					, [DocumentType_MTV_ID] 
					, [DocumentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[DocumentType_MTV_ID])
					, [AttachmentType_MTV_ID] 
					, [AttachmentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[AttachmentType_MTV_ID]) 
					, [ImageName] 
					, [Description_] 
					, [Path_] 
					, [RefNo] 
					, [RefNo2] 
					, [RefID] 
					, [RefID2] 
					, [IsPublic] 
					, [Location] 
					, [DRIVER_ID] 
					, [DRIVER_NAME] = [POMS_DB].[dbo].[F_Get_PinnacleDriverName_From_DriverID] (ilv.[DRIVER_ID])
					, [DeliveryORPickup_Name] 
					, [DeliveryORPickup_Date] 
					, [ThumbnailGUID] 
					, [AddedBy] = (case when [AddedByUserid] is not null then afni.FullName else afnn.FullName end)
					, [AddedOn] 
					, [ModifiedBy] = mfni.FullName
					, [ModifiedOn] 
					, TotalRecords
					from (
					select [OrderID] = @ORDER_ID
						, [OD_ID] = img.[Entry No]
						, [DocumentType_MTV_ID] = (case when POD.[Type] is null then
							(case when img.[Entity Type ID] = 10000 then 111100
								when img.[Entity Type ID] = 20000 then 111101
								when img.[Entity Type ID] = 30000 then 111102
								when img.[Entity Type ID] = 40000 then 111103
								when img.[Entity Type ID] = 50000 then 111106
								when img.[Entity Type ID] = 60000 then 111100
								else 0 end)
							when POD.[Type] = 1 then 111105
							when POD.[Type] = 2 then 111104
							else 0 end)
						, [AttachmentType_MTV_ID] = (case when img.[Source] = 0 then 128101
							when img.[Source] = 4 then 128102
							else 128100 end)
						, [ImageName] = img.[Image Name]
						, [Description_] = img.[Description]
						, [Path_] = img.[Path]
						, [RefNo] = img.[Ref No_]
						, [RefNo2] = null
						, [RefID] = img.[RefNoInt]
						, [RefID2] = null
						, [IsPublic] = (case when img.[Private] = 0 then 1 else 0 end) 
						, [Location] = (case when POD.[Type] is null then null else POD.[Received Location] end)
						, [DRIVER_ID] = (case when POD.[Type] is null then null else POD.[Delivery By] end)
						, [DeliveryORPickup_Name] = (case when POD.[Type] is null then null else POD.[Received By] end)
						, [DeliveryORPickup_Date] = (case when POD.[Type] is null then null else 
							(case when Year(POD.[Delivery On]) < 2000 then null else POD.[Delivery On] end)
							end)
						, [ThumbnailGUID] = it.GUID_ + it.FileExt
						, [AddedByUserid] = (case when POD.[Type] is not null then null else img.[Added By] end)
						, [AddedByUsername] = (case when POD.[Type] is null then null else img.[Added By] end)
						, [AddedBy] = null
						, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (img.[Added On],@TimeZone_ID,null,@TimeZoneName)
						, [ModifiedByUserid] = img.[Modify By]
						, [ModifiedBy] = null
						, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (img.[Modify On],@TimeZone_ID,null,@TimeZoneName)
						, TotalRecords = @TotalRecords
					from [PinnacleArchiveDB].[dbo].[Metropolitan$Image] img with (nolock)
					left join [PinnacleProd].[dbo].[Metropolitan$Proof of Delivery] POD with (nolock) on img.[Order No] = POD.[Order No] 
					and img.[Ref No_] = cast(POD.[Entry No] as nvarchar(20)) 
					--and img.[RefNoInt] = POD.[Entry No] and img.[RefNoInt] is not null 
					and img.[Master Type ID] = 10190 and POD.ActiveStatus = 1
					left join [PinnacleProd].[dbo].[T_Image_Thumbnail] it with (nolock) on it.Image_Entry_No = img.[Entry No] and it.Is_Active = 1
					where img.[Order No] = @ORDER_NO and ((img.[Private] = 1 and @IsPublic = 0) or @IsPublic = 1) and img.IsActive = 1 and img.[Path] <> ''
					and ((img.[Master Type ID] = 10190 and POD.[Entry No] is not null) or (img.[Master Type ID] = 10110))
					and (@IsDocument is null 
						or (@IsDocument is not null and @IsDocument = 1 and POD.[Entry No] is null)
						or (@IsDocument is not null and @IsDocument = 0 and POD.[Entry No] is not null))
					and (@OD_ID = 0 or (img.[Entry No] = @OD_ID and @OD_ID > 0))
				) ilv outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ilv.[AddedByUserid]) afni
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ilv.[AddedByUsername]) afnn
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ilv.[ModifiedByUserid]) mfni
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147104)
	begin
		select @TotalRecords = (@TotalRecords + count(img.[Entry No])) from [PinnacleArchiveDB].[dbo].[Metropolitan$Image] img with (nolock)
		left join [PinnacleProd].[dbo].[Metropolitan$Proof of Delivery] POD with (nolock) on img.[Order No] = POD.[Order No] 
		and img.[Ref No_] = cast(POD.[Entry No] as nvarchar(20)) 
		--and img.[RefNoInt] = POD.[Entry No] and img.[RefNoInt] is not null 
		and img.[Master Type ID] = 10190 and POD.ActiveStatus = 1
		where img.[Order No] = @ORDER_NO and ((img.[Private] = 1 and @IsPublic = 0) or @IsPublic = 1) and img.IsActive = 1 and img.[Path] <> ''
		and ((img.[Master Type ID] = 10190 and POD.[Entry No] is not null) or (img.[Master Type ID] = 10010))
		and (@IsDocument is null 
			or (@IsDocument is not null and @IsDocument = 1 and POD.[Entry No] is null)
			or (@IsDocument is not null and @IsDocument = 0 and POD.[Entry No] is not null))
		and (@OD_ID = 0 or (img.[Entry No] = @OD_ID and @OD_ID > 0))

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [OD_ID] , [DocumentType_MTV_ID] , [DocumentType_Name] , [AttachmentType_MTV_ID] , [AttachmentType_Name] , [ImageName] , [Description_] , [Path_] , [RefNo] , [RefNo2] , [RefID] , [RefID2] 
			, [IsPublic] , [Location] , [DRIVER_ID] , [DRIVER_NAME] , [DeliveryORPickup_Name] , [DeliveryORPickup_Date] , [ThumbnailGUID] , [AddedBy] , [AddedOn] , [ModifiedBy] , [ModifiedOn] , TotalRecords)
			select [OrderID] 
				, [OD_ID] 
				, [DocumentType_MTV_ID] 
				, [DocumentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[DocumentType_MTV_ID])
				, [AttachmentType_MTV_ID] 
				, [AttachmentType_Name] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ilv.[AttachmentType_MTV_ID]) 
				, [ImageName] 
				, [Description_] 
				, [Path_] 
				, [RefNo] 
				, [RefNo2] 
				, [RefID] 
				, [RefID2] 
				, [IsPublic] 
				, [Location] 
				, [DRIVER_ID] 
				, [DRIVER_NAME] = [POMS_DB].[dbo].[F_Get_PinnacleDriverName_From_DriverID] (ilv.[DRIVER_ID])
				, [DeliveryORPickup_Name] 
				, [DeliveryORPickup_Date] 
				, [ThumbnailGUID] 
				, [AddedBy] = (case when [AddedByUserid] is not null then afni.FullName else afnn.FullName end)
				, [AddedOn] 
				, [ModifiedBy] = mfni.FullName
				, [ModifiedOn] 
				, TotalRecords
				from (
				select [OrderID] = @ORDER_ID
					, [OD_ID] = img.[Entry No]
					, [DocumentType_MTV_ID] = (case when POD.[Type] is null then
						(case when img.[Entity Type ID] = 10000 then 111100
							when img.[Entity Type ID] = 20000 then 111101
							when img.[Entity Type ID] = 30000 then 111102
							when img.[Entity Type ID] = 40000 then 111103
							when img.[Entity Type ID] = 50000 then 111106
							when img.[Entity Type ID] = 60000 then 111100
							else 0 end)
						when POD.[Type] = 1 then 111105
						when POD.[Type] = 2 then 111104
						else 0 end)
					, [AttachmentType_MTV_ID] = (case when img.[Source] = 0 then 128101
						when img.[Source] = 4 then 128102
						else 128100 end)
					, [ImageName] = img.[Image Name]
					, [Description_] = img.[Description]
					, [Path_] = img.[Path]
					, [RefNo] = img.[Ref No_]
					, [RefNo2] = null
					, [RefID] = img.[RefNoInt]
					, [RefID2] = null
					, [IsPublic] = (case when img.[Private] = 0 then 1 else 0 end) 
					, [Location] = (case when POD.[Type] is null then null else POD.[Received Location] end)
					, [DRIVER_ID] = (case when POD.[Type] is null then null else POD.[Delivery By] end)
					, [DeliveryORPickup_Name] = (case when POD.[Type] is null then null else POD.[Received By] end)
					, [DeliveryORPickup_Date] = (case when POD.[Type] is null then null else 
						(case when Year(POD.[Delivery On]) < 2000 then null else POD.[Delivery On] end)
						end)
					, [ThumbnailGUID] = it.GUID_ + it.FileExt
					, [AddedByUserid] = (case when POD.[Type] is not null then null else img.[Added By] end)
					, [AddedByUsername] = (case when POD.[Type] is null then null else img.[Added By] end)
					, [AddedBy] = null
					, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (img.[Added On],@TimeZone_ID,null,@TimeZoneName)
					, [ModifiedByUserid] = img.[Modify By]
					, [ModifiedBy] = null
					, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (img.[Modify On],@TimeZone_ID,null,@TimeZoneName)
					, TotalRecords = @TotalRecords
				from [PinnacleArchiveDB].[dbo].[Metropolitan$Image] img with (nolock)
				left join [PinnacleProd].[dbo].[Metropolitan$Proof of Delivery] POD with (nolock) on img.[Order No] = POD.[Order No] 
				and img.[Ref No_] = cast(POD.[Entry No] as nvarchar(20)) 
				--and img.[RefNoInt] = POD.[Entry No] and img.[RefNoInt] is not null 
				and img.[Master Type ID] = 10190 and POD.ActiveStatus = 1
				left join [PinnacleProd].[dbo].[T_Image_Thumbnail] it with (nolock) on it.Image_Entry_No = img.[Entry No] and it.Is_Active = 1
				where img.[Order No] = @ORDER_NO and ((img.[Private] = 1 and @IsPublic = 0) or @IsPublic = 1) and img.IsActive = 1 and img.[Path] <> ''
				and ((img.[Master Type ID] = 10190 and POD.[Entry No] is not null) or (img.[Master Type ID] = 10110))
				and (@IsDocument is null 
					or (@IsDocument is not null and @IsDocument = 1 and POD.[Entry No] is null)
					or (@IsDocument is not null and @IsDocument = 0 and POD.[Entry No] is not null))
				and (@OD_ID = 0 or (img.[Entry No] = @OD_ID and @OD_ID > 0))
			) ilv outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ilv.[AddedByUserid]) afni
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ilv.[AddedByUsername]) afnn
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ilv.[ModifiedByUserid]) mfni
		end
	end

	return
	

end
GO
