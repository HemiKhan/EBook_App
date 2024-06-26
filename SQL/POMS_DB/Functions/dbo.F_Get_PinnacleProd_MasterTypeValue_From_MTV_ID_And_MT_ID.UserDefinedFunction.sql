USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID]  
(
	@MT_ID int
	,@MTV_ID int
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@MTV_ID,0) != 0 and isnull(@MT_ID,0) != 0
	begin
		select @Ret = mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = @MT_ID and mtv.[ID] = @MTV_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
