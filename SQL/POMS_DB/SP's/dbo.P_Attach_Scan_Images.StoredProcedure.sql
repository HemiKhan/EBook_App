USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Attach_Scan_Images]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @Ret_Return_Code bit = 0 Declare @Ret_Return_Text nvarchar(max) = '' Declare @Ret_Execution_Error nvarchar(max) = '' exec [POMS_DB].[dbo].[P_Attach_Scan_Images] '[{"Type":1,"Scan_GUID":"c438a630-8550-1ed0-b723-c12f262c1242","Barcode":"8650493800340001","DamageCodes":["BOX-DAMAGE","ITEM-DAMAGE"],"DamageNote":"dhdhhdhd","audioFilesInfo":null,"fileInfo":[{"RequestID":"a95f9c6d-274e-4f2b-8720-5f928647aafb","FileName":"15d6f741-2c7f-45dd-9ea4-3aa54a83fca3","FileExt":".jpg","Description":"Bsbsbsbb","Path":"\\Content\\OrderImages\\15d6f741-2c7f-45dd-9ea4-3aa54a83fca3..jpg","FileSize":3728350}],"ScanBy":"ABDULLAH.ARSHAD","ScanByID":934}]' ,@Ret_Return_Code out ,@Ret_Return_Text out ,@Ret_Execution_Error out select @Ret_Return_Code ,@Ret_Return_Text ,@Ret_Execution_Error
-- =============================================
CREATE PROCEDURE [dbo].[P_Attach_Scan_Images]
	@pJson nvarchar(max)
	,@ppReturn_Code bit output
	,@ppReturn_Text nvarchar(max) output
	,@ppExecution_Error nvarchar(max) output
AS
BEGIN
	
	set @ppReturn_Code = 0
	set @ppReturn_Text = ''
	set @ppExecution_Error = ''

	set @pJson = isnull(@pJson,'')

	if ISJSON(@pJson) = 0
	begin
		set @ppReturn_Text = 'Valid Json Required'
		return
	end

	--set @ppReturn_Code = 0
	--set @ppReturn_Text = 'Testing; Test2; Test3'
	--set @ppExecution_Error = ''
	--return

	Declare @ScanImages table
	(ID int identity(1,1) not null
	,[Type] int
	,Scan_GUID nvarchar(36)
	,Barcode nvarchar(20)
	,DamageCodes nvarchar(max)
	,DamageNote nvarchar(1000)
	,Images nvarchar(max)
	,AudioFilesInfo nvarchar(max)
	,ScanBy nvarchar(150)
	,ScanByID int)

	insert into @ScanImages ([Type] ,Scan_GUID ,Barcode ,DamageCodes ,DamageNote ,Images ,AudioFilesInfo ,ScanBy ,ScanByID)
	select j.[Type]
	,j.Scan_GUID
	,j.Barcode
	,j.DamageCodes
	,j.DamageNote
	,j.Images
	,j.AudioFilesInfo
	,j.ScanBy
	,j.ScanByID
	from OpenJson(@pJson)
	WITH (
		[Type] int '$.Type'
		,Scan_GUID nvarchar(36) '$.Scan_GUID'
		,Barcode nvarchar(20) '$.Barcode'
		,DamageCodes nvarchar(max) '$.DamageCodes' as json
		,DamageNote nvarchar(1000) '$.DamageNote'
		,Images nvarchar(max) '$.fileInfo' as json
		,AudioFilesInfo nvarchar(max) '$.audioFilesInfo' as json
		,ScanBy nvarchar(150) '$.ScanBy'
		,ScanByID int '$.ScanByID'
	) j

	Declare @Type int = 0
	Declare @Scan_GUID nvarchar(36) = ''
	Declare @Barcode nvarchar(20) = ''
	Declare @DamageCodes nvarchar(max) = ''
	Declare @DamageNote nvarchar(1000) = ''
	Declare @Images nvarchar(max) = ''
	Declare @AudioFilesInfo nvarchar(max) = ''
	Declare @ScanBy nvarchar(150) = ''
	Declare @ScanByID int = 0
	Declare @ORDER_ID int = 0
	Declare @ORDER_NO nvarchar(20) = ''
	Declare @TRACKING_NO nvarchar(20) = ''
	Declare @OI_ID int = 0
	Declare @GetRecordType_MTV_ID int = 0
	Declare @NewRelabelCount int = 0
	Declare @OIS_ID int = 0
	Declare @IsImagesExists bit = 0
	Declare @IsAudioFileExists bit = 0
	Declare @RowReturnCode bit = 1
	Declare @DocumentType_MTV_ID int = 0
	Declare @AttachmentType_MTV_ID int = 0

	Declare @ID int = 1
	Declare @MaxCount int = 0
	select @MaxCount = max(ID) from @ScanImages
	set @MaxCount = isnull(@MaxCount,0)
	while @ID  <= @MaxCount
	begin

		Begin Try

			set @IsImagesExists = 0
			set @RowReturnCode = 1

			Declare @ImagesTable table
			(ID int identity(1,1) not null
			,RequestID nvarchar(36)
			,[FileName] nvarchar(36) 
			,FileExt nvarchar(10)
			,[Description] nvarchar(250)
			,[Path] nvarchar(250)
			,FileSize int)

			Declare @AudioFileTable table
			(ID int identity(1,1) not null
			,[FileName] nvarchar(36) 
			,FileExt nvarchar(10)
			,[Path] nvarchar(250)
			,FileSize int)

			Declare @DamageCodesList table (Code nvarchar(20))

			select @Type = si.[Type], @Scan_GUID = si.Scan_GUID, @Barcode = si.Barcode, @DamageCodes = si.DamageCodes, @DamageNote = si.DamageNote, @Images = si.Images, @AudioFilesInfo = si.AudioFilesInfo
			, @ScanBy = si.Images, @ScanByID = si.ScanByID from @ScanImages si where si.ID = @ID 
		
			select @ORDER_ID = oib.ORDER_ID ,@TRACKING_NO = oib.TRACKING_NO ,@OI_ID = oib.OI_ID ,@GetRecordType_MTV_ID = oib.GetRecordType_MTV_ID ,@NewRelabelCount = oib.RelabelCount 
			from [POMS_DB].[dbo].[F_Get_OrderInfo_By_Barcode] (@Barcode ,@ScanBy) oib
		
			set @ORDER_NO = cast(@ORDER_ID as nvarchar(20))

			select @OIS_ID = ois.OIS_ID from [POMS_DB].[dbo].[T_Order_Item_Scans] ois with (nolock) where ois.OIS_GUID = @Scan_GUID
			set @OIS_ID = isnull(@OIS_ID,0)

			if @OIS_ID = 0
			begin
				select @OIS_ID = BSH_ID from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History Ext] with (nolock) where lower([GUID]) = lower(@Scan_GUID)
				set @OIS_ID = isnull(@OIS_ID,0)	
			end

			Begin Transaction

			if (@OIS_ID > 0)
			begin
				set @Images = isnull(@Images,'')
				if ISJSON(@Images) = 1
				begin
					set @IsImagesExists = 1

					insert into @ImagesTable (RequestID ,[FileName] ,FileExt ,[Description] ,[Path] ,FileSize)
					select i.RequestID
					,i.[FileName]
					,i.FileExt
					,[Description]=isnull(i.[Description],'')
					,i.[Path]
					,i.FileSize 
					from OpenJson(@Images)
					WITH (
						RequestID nvarchar(36) '$.RequestID'
						,[FileName] nvarchar(36) '$.FileName'
						,FileExt nvarchar(10) '$.FileExt'
						,[Description] nvarchar(250) '$.Description'
						,[Path] nvarchar(250) '$.Path'
						,FileSize int '$.FileSize'
					) i

					if @GetRecordType_MTV_ID in (147100,147101,147102)
					begin

						set @DocumentType_MTV_ID = 111103
						set @AttachmentType_MTV_ID = (case when @Type = 0 then 128102 when @Type = 1 then 128103 else 0 end)

						insert into [POMS_DB].[dbo].[T_Order_Docs] ([ORDER_ID] ,[DocumentType_MTV_ID] ,[AttachmentType_MTV_ID] ,[ImageName] ,[Description_] ,[Path_] ,[RefNo] ,[RefNo2] ,[RefID] ,[RefID2] ,[IsPublic] ,[AddedBy])
						select @ORDER_ID as Order_ID, @DocumentType_MTV_ID, @AttachmentType_MTV_ID, [ImageName] = ([FileName] + '.' + FileExt)
						, [Description], [Path], @Barcode, '', @OIS_ID, 0, 0, @ScanBy as [AddedBy] 
						from @ImagesTable order by ID

					end
					else if @GetRecordType_MTV_ID in (147103,147104,147105)
					begin
						
						Declare @DocLineNo int = 0
						Declare @EntityType int = ''
						Declare @MasterDocLineNo int = 10000
						Declare @MasterTypeID nvarchar(20) = '10010'
						Declare @RefNo nvarchar(20) = ''
						Declare @LineNo int = 0
						Declare @CurrentDate datetime = getutcdate()
						
						select @DocLineNo = [Line No] from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] where [Item Tracking No] = @Barcode and [Sales Order No] = @ORDER_NO
						set @DocLineNo = ISNULL(@DocLineNo,0)
						set @EntityType = case when @RefNo !='' then 70000 else 20000 end
						set @RefNo = case when @RefNo != '' then @RefNo else @Barcode end
						
						INSERT INTO [PinnacleProd].[dbo].[Metropolitan$Image] ([Order No] ,[Master Type ID] ,[Entity Type ID] ,[Document Line No] ,[Master Document Line No] ,[Line No] 
						,[Image Name] ,[Description] ,[Source] ,[Path] ,[SO Created] ,[Added On] ,[Added By] , [FileSize] ,[Ref No_] ,[Modify On] ,[Modify By] ,[Private] ,[RefNoInt])
						select @ORDER_NO ,@MasterTypeID ,@EntityType ,@DocLineNo ,@MasterDocLineNo 
						,[LineNo] = isnull((select max(i.[Line No]) from [PinnacleProd].[dbo].[Metropolitan$Image] i with (nolock) where [Order No] = @ORDER_NO
							and i.[Master Type ID] = @MasterTypeID and i.[Entity Type ID] = @EntityType and i.[Document Line No] = @DocLineNo),0) + 10000 --(it.ID * 10000)
						,ImageName = (it.[FileName] + '.' + it.FileExt) ,it.[Description] ,4 ,it.[Path] ,1 ,getutcdate() ,@ScanByID , it.FileSize 
						,@OIS_ID ,getutcdate() ,0 ,1 ,@OIS_ID from @ImagesTable it
						
					end

				end

				set @AudioFilesInfo = isnull(@AudioFilesInfo,'')
				if ISJSON(@AudioFilesInfo) = 1
				begin
					set @IsAudioFileExists = 1

					insert into @AudioFileTable ([FileName] ,FileExt ,[Path] ,FileSize)
					select i.[FileName]
					,i.FileExt
					,i.[Path]
					,i.FileSize 
					from OpenJson(@Images)
					WITH (
						[FileName] nvarchar(36) '$.FileName'
						,FileExt nvarchar(10) '$.FileExt'
						,[Path] nvarchar(250) '$.Path'
						,FileSize int '$.FileSize'
					) i

					if @GetRecordType_MTV_ID in (147100,147101,147102)
					begin

						set @DocumentType_MTV_ID = 152101
						set @AttachmentType_MTV_ID = 128105

						insert into [POMS_DB].[dbo].[T_Order_Docs] ([ORDER_ID] ,[DocumentType_MTV_ID] ,[AttachmentType_MTV_ID] ,[ImageName] ,[Description_] ,[Path_] ,[RefNo] ,[RefNo2] ,[RefID] ,[RefID2] ,[IsPublic] ,[AddedBy])
						select @ORDER_ID as Order_ID, @DocumentType_MTV_ID, @AttachmentType_MTV_ID, [ImageName] = ([FileName] + '.' + FileExt)
						, '', [Path], @Barcode, '', @OIS_ID, 0, 0, @ScanBy as [AddedBy] 
						from @AudioFileTable order by ID

					end

				end

				if (@Type = 0)
				begin
					if (@IsImagesExists = 0)
					begin
						set @RowReturnCode = 0
						set @ppReturn_Text = (case when @ppReturn_Text = '' then @Barcode + ' Images Required' else @ppReturn_Text + '; ' + @Barcode + ' Images Required' end)
					end
					else
					begin
						set @RowReturnCode = 1
						set @ppReturn_Code = 1
						set @ppReturn_Text = @Barcode + ' Images Added'
					end
				end
				else if (@Type = 1)
				begin
					set @DamageCodes = isnull(@DamageCodes,'')
					if ISJSON(@DamageCodes) = 1
					begin
						insert into @DamageCodesList (Code)
						select fdc.Code from (
							select Code = upper(isnull(dc.Code,''))
							from OpenJson(@DamageCodes)
							WITH (
								Code nvarchar(20) '$'
							) dc
						) fdc where fdc.Code != ''
						
						if @GetRecordType_MTV_ID in (147100,147101,147102)
						begin

							if (@IsImagesExists = 0)
							begin
								if not exists(select oisd.OIS_ID from [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] oisd with (nolock) where oisd.OIS_ID = @OIS_ID)
								begin
									set @RowReturnCode = 0
									set @ppReturn_Text = (case when @ppReturn_Text = '' then @Barcode + ' Damage Images Required' else @ppReturn_Text + '; ' + @Barcode + ' Damage Images Required' end)
								end
							end
							else
							begin
								if exists(select oisd.Damage_MTV_CODE from [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] oisd with (nolock) where oisd.OIS_ID = @OIS_ID and oisd.IsActive = 1
									and oisd.Damage_MTV_CODE not in (select dcl.Code from @DamageCodesList dcl))
								begin
									update oisd
									set oisd.IsActive = 0
									,oisd.ModifiedBy = @ScanBy
									,oisd.ModifiedOn = getutcdate()
									from [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] oisd where oisd.OIS_ID = @OIS_ID and oisd.IsActive = 1
									and oisd.Damage_MTV_CODE not in (select dcl.Code from @DamageCodesList dcl)
								end

								if exists(select oisd.Damage_MTV_CODE from [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] oisd with (nolock) where oisd.OIS_ID = @OIS_ID and oisd.IsActive = 0
									and oisd.Damage_MTV_CODE in (select dcl.Code from @DamageCodesList dcl))
								begin
									update oisd
									set oisd.IsActive = 1
									,oisd.ModifiedBy = @ScanBy
									,oisd.ModifiedOn = getutcdate()
									from [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] oisd where oisd.OIS_ID = @OIS_ID and oisd.IsActive = 0
									and oisd.Damage_MTV_CODE in (select dcl.Code from @DamageCodesList dcl)
								end

								if not exists(select oisd.Damage_MTV_CODE from [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] oisd with (nolock) where oisd.OIS_ID = @OIS_ID 
									and oisd.Damage_MTV_CODE in (select dcl.Code from @DamageCodesList dcl))
								begin
									insert into [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] (OIS_ID, Damage_MTV_CODE, AddedBy)
									Select @OIS_ID, dcl.Code, @ScanBy from @DamageCodesList dcl where dcl.Code not in (select oisd.Damage_MTV_CODE from [POMS_DB].[dbo].[T_Order_Item_Scans_Damage] oisd with (nolock) where oisd.OIS_ID = @OIS_ID)
								end

								set @RowReturnCode = 1
								set @ppReturn_Code = 1
								set @ppReturn_Text = @Barcode + ' Damage Updated'
							end

						end
						else if @GetRecordType_MTV_ID in (147103,147104,147105)
						begin
						
							if exists(select 1 from [PinnacleProd].[dbo].[Metropolitan_ScanItemCondition] with (nolock) where [ScanID] = @OIS_ID)
							begin
								update sic
								set sic.[ItemCondition] = (case when isnull(@DamageCodes,'') <> '' then 20000 else 10000 end)
								, sic.[DateReported] = getutcdate()
								, sic.[ReportedBy] = @ScanByID
								, sic.[DateModified] = getutcdate()
								, sic.[ModifiedBy] = @ScanByID
								from [PinnacleProd].[dbo].[Metropolitan_ScanItemCondition] sic
								where sic.[ScanID] = @OIS_ID
							end
							else
							begin
								insert into [PinnacleProd].[dbo].[Metropolitan_ScanItemCondition] ([ScanID], [OrderNo], [ItemBarcode], [ItemID], [ItemCondition], [LocationID], [Hub], [ManifestID], [ManifestSource], [ManifestType], [IsPublic], [DateReported], [ReportedBy], [DateAdded], [AddedBy])
								select @OIS_ID, @ORDER_NO, @Barcode, @OI_ID
									, ItemCondition = (case when isnull(@DamageCodes,'') <> '' then 20000 else 10000 end)
									, [Location ID], [Location], [ManifestID]
									, [ManifestSource] = 0 --case when [ManifestID] = 0 then 0 else [ManifestSource] end
									, [Manifest Type] = case when [ManifestID] = 0 then 0 else [ManifestSource] end --Manifest Source is a Manifest Type
									, 1, GETUTCDATE(), @ScanByID, GETUTCDATE(), @ScanByID
								from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) where bsh.[Entry No] = @OIS_ID
							end

							update	[PinnacleProd].[dbo].[Metro_OrderItem_Data] set [ItemCondition] = 20000 , [DateModified] = getutcdate() where [BarcodeNo] = @Barcode

							set @RowReturnCode = 1
							set @ppReturn_Code = 1
							set @ppReturn_Text = @Barcode + ' Damage Updated'

						end

					end
				end

				if (@RowReturnCode = 0 and @@TRANCOUNT > 0)
				begin
					ROLLBACK;
				end
				else if (@RowReturnCode = 1 and @@TRANCOUNT > 0)
				begin
					COMMIT; 
				end

			end

		End Try
		Begin catch
			if @@TRANCOUNT > 0
			begin
				ROLLBACK; 
			end
			set @ppReturn_Text = (case when @ppReturn_Text = '' then @Barcode + ' ' + cast(@ID as nvarchar(20)) + ' Internal Server Error' else @ppReturn_Text + '; ' + @Barcode + ' ' + cast(@ID as nvarchar(20)) + ' Internal Server Error' end)
			--set @ppReturn_Text = (case when @ppReturn_Text = '' then @Barcode + ' ' + cast(@ID as nvarchar(20)) + ' ' + ERROR_MESSAGE() else @ppReturn_Text + '; ' + @Barcode + ' ' + cast(@ID as nvarchar(20)) + ' ' + ERROR_MESSAGE() end)
			Set @ppExecution_Error = 'P_Attach_Scan_Images: ' + ' ' + cast(@ID as nvarchar(20)) + ERROR_MESSAGE()
		End catch

		set @ID  = @ID  + 1

	end

END
GO
