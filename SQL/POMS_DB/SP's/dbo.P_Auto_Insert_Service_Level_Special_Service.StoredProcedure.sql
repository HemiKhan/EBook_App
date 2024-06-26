USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Auto_Insert_Service_Level_Special_Service]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Auto_Insert_Service_Level_Special_Service]
	
AS
BEGIN
	
	select max([SLSS_ID]) from [POMS_DB].[dbo].[T_Service_Level_Special_Service] with (nolock)

	insert into [POMS_DB].[dbo].[T_Service_Level_Special_Service] ([ST_CODE],[SSL_CODE],[Description],[IsAvailableForPickup],[IsAvailableForDelivery],[IsOpted],[IsActive],[AddedBy])
	select STCODE ,SSLCODE ,null ,[IsAvailableForPickup] ,[IsAvailableForDelivery] ,0 ,1 ,'AUTOIMPORT' from (
	SELECT STCODE=st_.[ST_CODE] ,SSLCODE=ssl_.[SSL_CODE] 
	,[IsAvailableForPickup]=(case when st_.Type_MTV_ID = 125100 and ssl_.IsAvailableForPickup = 1 then 1 else 0 end)
	,[IsAvailableForDelivery]=(case when st_.Type_MTV_ID <> 125100 and ssl_.IsAvailableForDelivery = 1 then 1 else 0 end)
	,st_.Type_MTV_ID
	FROM [POMS_DB].[dbo].[T_Special_Services_List] ssl_ with (nolock) cross apply [POMS_DB].[dbo].[T_Service_Type] st_ with (nolock)
	where (st_.[ST_CODE] + ssl_.[SSL_CODE]) not in (select ([ST_CODE] + [SSL_CODE]) from [POMS_DB].[dbo].[T_Service_Level_Special_Service] with (nolock))
	) A where [IsAvailableForDelivery] = 1 or [IsAvailableForPickup] = 1
	order by A.Type_MTV_ID,A.STCODE,A.SSLCODE
	
	select max([SLSS_ID]) from [POMS_DB].[dbo].[T_Service_Level_Special_Service] with (nolock)

END
GO
