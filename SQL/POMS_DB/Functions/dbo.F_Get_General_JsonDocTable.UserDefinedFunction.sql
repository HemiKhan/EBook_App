USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_General_JsonDocTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_General_JsonDocTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_General_JsonDocTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(FileGUID nvarchar(36)
,Path_ nvarchar(250)
,OriginalFileName nvarchar(250)
,FileExt nvarchar(10)
,Description_ nvarchar(250)
,IsPublic bit
,AttachmentType_MTV_ID int
,RefNo nvarchar(40)
,RefNo2 nvarchar(40)
,RefID int
,RefID2 int
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
	
	insert into @ReturnTable (FileGUID ,Path_ ,OriginalFileName ,FileExt ,Description_ ,IsPublic ,AttachmentType_MTV_ID ,RefNo ,RefNo2 ,RefID ,RefID2)
	select * from (
		select FileGUID 
		,Path_ ,OriginalFileName ,FileExt ,Description_ ,IsPublic ,AttachmentType_MTV_ID
		,RefNo 
		,RefNo2 
		,RefID 
		,RefID2 
		from OpenJson(@Json)
		WITH (
			OrderFileGUID nvarchar(36) '$.fileguid'
			,Path_ nvarchar(250) '$.path'
			,OriginalFileName nvarchar(250) '$.filename'
			,FileExt nvarchar(10) '$.fileext'
			,Description_ nvarchar(250) '$.description'
			,IsPublic bit '$.ispublic'
			,AttachmentType_MTV_ID int '$.attachmenttype'
			,RefNo int '$.refno'
			,RefNo2 int '$.refno2'
			,RefID int '$.refid'
			,RefID2 int '$.refid2'
			,filelist nvarchar(max) '$.filelist' as json
		) I_Docs
		OUTER APPLY OpenJson(I_Docs.[filelist])
		WITH (
			FileGUID nvarchar(36) '$.fileguid'
		) I_Docs2
	) ilv 
	order by isnull(ilv.RefNo,''),isnull(ilv.RefID,0)

	return

end
GO
