USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Google_Address_Validation_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[P_Google_Address_Validation_IU]
	@GAVL_ID int = 0
	,@RegionCode nvarchar(20)
	,@FullAddress nvarchar(250)
	,@Json text
AS
BEGIN
	
	set @GAVL_ID = isnull(@GAVL_ID,0)
	set @RegionCode = upper(isnull(@RegionCode,''))
	set @FullAddress = lower(isnull(@FullAddress,''))
	
	if (@GAVL_ID > 0)
	begin
		Update gavl Set
			gavl.RegionCode = @RegionCode
			,gavl.FullAddress = @FullAddress
			,gavl.ResponseJson = @Json
			,gavl.ModifiedOn = getutcdate()
		from [POMS_DB].[dbo].[T_Google_Address_Validation_Log] gavl where gavl.GAVL_ID = @GAVL_ID
	end
	else
	begin
		insert into [POMS_DB].[dbo].[T_Google_Address_Validation_Log] (RegionCode, FullAddress, ResponseJson)
		Values (@RegionCode, @FullAddress, @Json)
	end

END
GO
