USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonSpecialServiceTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_JsonSpecialServiceTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonSpecialServiceTable]
(	
	@Json nvarchar(max)
	,@IsPickup bit
	,@ST_CODE nvarchar(20)
)
RETURNS @ReturnTable TABLE 
(OSS_ID int
,SSL_CODE nvarchar(10)
,Description_ nvarchar(250)
,IsPublic bit
,Mints int
,Floor_ int
,EST_Amount decimal(18,6)
,Days_ int
,From_Date date
,To_Date date
,Man int
,SLSS_ID int
,IsDelete bit
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
	select OSS_ID = isnull(OSS_ID,0)
	,SSL_CODE = SS.SSL_CODE
	,Description_ = isnull(SS.Description_,'')
	,IsPublic = SS.IsPublic
	,Mints = isnull(SS.Mints,0)
	,Floor_ = isnull(SS.Floor_,0)
	,EST_Amount = isnull(SS.EST_Amount,0.00)
	,Days_ = isnull(SS.Days_,0)
	,SS.From_Date
	,SS.To_Date
	,Man = isnull(SS.Man,0)
	,[SLSS_ID] = isnull((case when @IsPickup = 1 then
		(select top 1 [SLSS_ID] FROM [POMS_DB].[dbo].[T_Service_Level_Special_Service] slss with (nolock) where slss.SSL_CODE = SS.SSL_CODE and slss.ST_CODE = @ST_CODE and slss.IsAvailableForPickup = 1)
		else
		(select top 1 [SLSS_ID] FROM [POMS_DB].[dbo].[T_Service_Level_Special_Service] slss with (nolock) where slss.SSL_CODE = SS.SSL_CODE and slss.ST_CODE = @ST_CODE and slss.IsAvailableForDelivery = 1)
		end),0)
	,[IsDelete]=isnull([IsDelete],0)
	from OpenJson(@Json)
	WITH (
		OSS_ID int '$.oss_id'
		,SSL_CODE nvarchar(10) '$.code'
		,Description_ nvarchar(250) '$.description'
		,IsPublic bit '$.ispublic'
		,Mints int '$.minutes'
		,Floor_ int '$.floor'
		,EST_Amount decimal(18,6) '$.amount'
		,Days_ int '$.days'
		,From_Date date '$.fromdate'
		,To_Date date '$.todate'
		,Man int '$.man'
		,IsDelete bit '$.isdelete'
	) SS

	return

end
GO
