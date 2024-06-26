USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_ProcessScanEntries_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_ProcessScanEntries_JsonTable] ('[]')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_ProcessScanEntries_JsonTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(ID int identity(1,1) not null
,RequestID nvarchar(36)
,OIS_ID int
,BARCODE nvarchar(20)
,OIS_GUID nvarchar(36)
,RelabelCount int
,ScanType_MTV_ID int
,LOCATION_ID nvarchar(20)
,HUB_CODE nvarchar(20)
,DeviceCode_MTV_CODE nvarchar(20)
,ScanTime datetime
,ScanBy nvarchar(150)
,ScanByID int
,MANIFEST_ID int
,ManifestType_MTV_ID int
,Lat nvarchar(30)
,Lng nvarchar(30)
,ScanAnytime bit
,AutoScan bit
,IsRelabelRequired bit
,IsActive bit
,IsError bit
,ErrorMsg nvarchar(max)
,IsJsonBasicValidation bit
,WarningMsg nvarchar(max)
)
AS
begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end

	insert into @ReturnTable (RequestID ,OIS_ID ,BARCODE ,OIS_GUID ,RelabelCount ,ScanType_MTV_ID ,LOCATION_ID ,HUB_CODE ,DeviceCode_MTV_CODE ,ScanTime ,ScanBy ,ScanByID ,MANIFEST_ID ,ManifestType_MTV_ID ,Lat ,Lng ,ScanAnytime ,AutoScan ,IsRelabelRequired ,IsActive ,IsError ,ErrorMsg ,IsJsonBasicValidation ,WarningMsg)
	select RequestID = isnull(ois.RequestID,'')
		,OIS_ID = isnull(ois.OIS_ID,0)
		,BARCODE = isnull(ois.BARCODE,'')
		,OIS_GUID = isnull(ois.OIS_GUID,'')
		,RelabelCount = ois.RelabelCount
		,ScanType_MTV_ID = isnull(ois.ScanType_MTV_ID,0)
		,LOCATION_ID = isnull(ois.LOCATION_ID,'')
		,HUB_CODE = isnull(ois.HUB_CODE,'')
		,DeviceCode_MTV_CODE = isnull(ois.DeviceCode_MTV_CODE,'')
		,ScanTime = isnull(ois.ScanTime,getutcdate())
		,ScanBy = isnull(ois.ScanBy,'')
		,ScanByID = isnull(ois.ScanByID,0)
		,MANIFEST_ID = isnull(ois.MANIFEST_ID,0)
		,ManifestType_MTV_ID = isnull(ois.ManifestType_MTV_ID,0)
		,Lat = isnull(ois.Lat,'')
		,Lng = isnull(ois.Lng,'')
		,ScanAnytime = isnull(ois.ScanAnytime,0)
		,AutoScan = isnull(ois.AutoScan,0)
		,IsRelabelRequired = isnull(ois.IsRelabelRequired,0)
		,IsActive = isnull(ois.IsActive,1)
		,IsError = isnull(ois.IsError,0)
		,ErrorMsg = isnull(ois.ErrorMsg,'')
		,IsJsonBasicValidation = isnull(IsJsonBasicValidation,0)
		,WarningMsg = isnull(WarningMsg,'')
	from OpenJson(@Json)
	WITH (
		RequestID nvarchar(36) '$.RequestID'
		,OIS_ID int '$.OIS_ID'
		,BARCODE nvarchar(20) '$.BARCODE'
		,OIS_GUID nvarchar(36) '$.OIS_GUID'
		,RelabelCount int '$.RelabelCount'
		,ScanType_MTV_ID int '$.ScanType_MTV_ID'
		,LOCATION_ID nvarchar(20) '$.LOCATION_ID'
		,HUB_CODE nvarchar(20) '$.HUB_CODE'
		,DeviceCode_MTV_CODE nvarchar(20) '$.DeviceCode_MTV_CODE'
		,ScanTime datetime '$.ScanTime'
		,ScanBy nvarchar(150) '$.ScanBy'
		,ScanByID int '$.ScanByID'
		,MANIFEST_ID int '$.MANIFEST_ID'
		,ManifestType_MTV_ID int '$.ManifestType_MTV_ID'
		,Lat nvarchar(30) '$.Lat'
		,Lng nvarchar(30) '$.Lng'
		,ScanAnytime bit '$.ScanAnytime'
		,AutoScan bit '$.AutoScan'
		,IsRelabelRequired bit '$.IsRelabelRequired'
		,IsActive bit '$.IsActive'
		,IsError bit '$.IsError'
		,ErrorMsg nvarchar(max) '$.ErrorMsg'
		,IsJsonBasicValidation bit '$.IsJsonBasicValidation'
		,WarningMsg nvarchar(max) '$.WarningMsg'
	) ois order by ScanTime

	return

end
GO
