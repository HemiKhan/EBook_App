USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonDocTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_JsonDocTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonDocTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(FileGUID nvarchar(36)
,Path_ nvarchar(250)
,OriginalFileName nvarchar(250)
,FileExt nvarchar(10)
,Description_ nvarchar(250)
,DocumentType_MTV_ID int
,IsPublic bit
,AttachmentType_MTV_ID int
,RefNo nvarchar(40)
,RefNo2 nvarchar(40)
,RefID int
,RefID2 int
,RefGUID nvarchar(36)
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
	
	insert into @ReturnTable
	select * from (
		select FileGUID = (case when AttachmentType_MTV_ID = 128100 then OrderFileGUID
			when AttachmentType_MTV_ID = 128101 then (case when I_Docs2.ItemFileGUID is null then '' else I_Docs2.ItemFileGUID end)
			when AttachmentType_MTV_ID = 128102 then (case when I_Docs3.ItemFileGUID is null then '' else I_Docs3.ItemFileGUID end)
			else '' end)
		,Path_ ,OriginalFileName ,FileExt ,Description_ ,DocumentType_MTV_ID ,IsPublic ,AttachmentType_MTV_ID
		,RefNo = (case when AttachmentType_MTV_ID = 128100 then null
			when AttachmentType_MTV_ID = 128101 then (case when I_Docs2.barcode is null then null else I_Docs2.barcode end)
			when AttachmentType_MTV_ID = 128102 then (case when I_Docs3.barcode is null then null else I_Docs3.barcode end)
			else null end)
		,RefNo2 = (case when AttachmentType_MTV_ID = 128102 then (case when I_Docs3.scanguid is null then null else I_Docs3.scanguid end)
			else null end)
		,RefID = null
		,RefID2 = null
		,RefGUID = (case when AttachmentType_MTV_ID = 128100 then ''
			when AttachmentType_MTV_ID = 128101 then (case when I_Docs2.barcodeguid is null then '' else I_Docs2.barcodeguid end)
			when AttachmentType_MTV_ID = 128102 then (case when I_Docs3.scanguid is null then '' else I_Docs3.scanguid end)
			else '' end)
		from OpenJson(@Json)
		WITH (
			OrderFileGUID nvarchar(36) '$.fileguid'
			,Path_ nvarchar(250) '$.path'
			,OriginalFileName nvarchar(250) '$.filename'
			,FileExt nvarchar(10) '$.fileext'
			,Description_ nvarchar(250) '$.description'
			,DocumentType_MTV_ID int '$.documenttype'
			,IsPublic bit '$.ispublic'
			,AttachmentType_MTV_ID int '$.attachmenttype'
			,barcodeslist nvarchar(max) '$.barcodes' as json
			,itemscanlist nvarchar(max) '$.itemscan' as json
		) I_Docs
		OUTER APPLY OpenJson(I_Docs.[barcodeslist])
		WITH (
			barcode nvarchar(40) '$.barcode'
			,ItemFileGUID nvarchar(36) '$.fileguid'
			,barcodeguid nvarchar(36) '$.barcodeguid'
		) I_Docs2
		OUTER APPLY OpenJson(I_Docs.[itemscanlist])
		WITH (
			barcode nvarchar(40) '$.barcode'
			,ItemFileGUID nvarchar(36) '$.fileguid'
			,scanguid nvarchar(36) '$.scanguid'
		) I_Docs3
	) ilv 
	order by ilv.RefNo,isnull(ilv.RefID,0)

	return

end
GO
