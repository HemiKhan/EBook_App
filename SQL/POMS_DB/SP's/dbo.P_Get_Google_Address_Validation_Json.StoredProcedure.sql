USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Google_Address_Validation_Json]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Google_Address_Validation_Json]
	@RegionCode nvarchar(20)
	,@FullAddress nvarchar(250)
AS
BEGIN
	
	set @RegionCode = upper(isnull(@RegionCode,''))
	set @FullAddress = lower(isnull(@FullAddress,''))

	Declare @GAVL_ID int = 0
	Declare @Json nvarchar(max) = ''

	select @GAVL_ID = gavl.GAVL_ID, @Json = cast(gavl.ResponseJson as nvarchar(max))
	from [POMS_DB].[dbo].[T_Google_Address_Validation_Log] gavl with (nolock) 
	where gavl.RegionCode = @RegionCode and gavl.FullAddress = @FullAddress and gavl.IsActive = 1

	if (@GAVL_ID is not null)
	begin
		Update gavl Set
			gavl.Hits = gavl.Hits + 1
			,gavl.LastGetDateTime = getutcdate()
		from [POMS_DB].[dbo].[T_Google_Address_Validation_Log] gavl where gavl.GAVL_ID = @GAVL_ID
	end

	select @Json as [Json]

END
GO
