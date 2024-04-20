USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonOtherInfoTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_JsonOtherInfoTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonOtherInfoTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(Date_ date
,FromTime time(7)
,ToTime time(7)
,ST_CODE nvarchar(20)
,SST_CODE nvarchar(20)
,Instruction nvarchar(1000)
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

	Declare @Date date = getutcdate()
	
	insert into @ReturnTable
	select Date_ = (case when isnull(OtherInfo.Date_,'') = '' then null else OtherInfo.Date_ end)
		,FromTime = (case when isnull(OtherInfo.FromTime,'') = '' then null else OtherInfo.FromTime end)
		,ToTime = (case when isnull(OtherInfo.ToTime,'') = '' then null else OtherInfo.ToTime end)
		,OtherInfo.ST_CODE 
		,OtherInfo.SST_CODE 
		,OtherInfo.Instruction 
	from OpenJson(@Json)
	WITH (
		Date_ nvarchar(20) '$.reqdate'
		,FromTime nvarchar(20) '$.reqfromtime'
		,ToTime nvarchar(20) '$.reqtotime'
		,ST_CODE nvarchar(20) '$.servicetype'
		,SST_CODE nvarchar(20) '$.subservicetype'
		,Instruction nvarchar(1000) '$.driverinstruction'
	) OtherInfo

	return

end
GO
