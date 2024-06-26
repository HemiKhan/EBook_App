USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Google_Address_Validation_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Google_Address_Validation_IU]
	@ORDER_ID int
	,@AddressType_MTV_ID int
	,@FullAddress nvarchar(500)
	,@GoogleAPIType_MTV_ID int
	,@Json text
	,@IsNewRequest bit = 0
AS
BEGIN
	
	Declare @OGAVL_ID int = 0
	set @IsNewRequest = isnull(@IsNewRequest,0)
	
	if (@IsNewRequest = 0)
	begin
		select @OGAVL_ID = ogavl.OGAVL_ID from [POMS_DB].[dbo].[T_Order_Google_Address_Validation_Log] ogavl where ogavl.ORDER_ID = @ORDER_ID and ogavl.AddressType_MTV_ID = @AddressType_MTV_ID
		set @OGAVL_ID = isnull(@OGAVL_ID,0)
	end

	if (@OGAVL_ID > 0)
	begin
		Update ogavl Set
			ogavl.FullAddress = @FullAddress
			,ogavl.GoogleAPIType_MTV_ID = @GoogleAPIType_MTV_ID
			,ogavl.ResponseJson = @Json
			,ogavl.ModifiedOn = getutcdate()
		from [POMS_DB].[dbo].[T_Order_Google_Address_Validation_Log] ogavl where ogavl.OGAVL_ID = @OGAVL_ID
	end
	else
	begin
		insert into [POMS_DB].[dbo].[T_Order_Google_Address_Validation_Log] (ORDER_ID, AddressType_MTV_ID, FullAddress, GoogleAPIType_MTV_ID, ResponseJson)
		Values (@ORDER_ID, @AddressType_MTV_ID, @FullAddress, @GoogleAPIType_MTV_ID, @Json)
	end

END
GO
