USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_Client_Identifier_Value_From_Code]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_Client_Identifier_Value_From_Code]  
(
	@ORDER_ID int
	,@OIF_CODE nvarchar(20)
)
RETURNS nvarchar(250)
AS
BEGIN
	
	Declare @Ret nvarchar(250) = ''

	if isnull(@OIF_CODE,'') != ''
	begin
		select @Ret = oci.[Value_] from [POMS_DB].[dbo].[T_Order_Client_Identifier] oci with (nolock) where oci.OIF_CODE = @OIF_CODE and oci.ORDER_ID = @ORDER_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
