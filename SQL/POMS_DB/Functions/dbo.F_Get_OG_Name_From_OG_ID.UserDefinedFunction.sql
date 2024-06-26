USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_OG_Name_From_OG_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_OG_Name_From_OG_ID]  
(
	@OG_ID int
)
RETURNS nvarchar(150)
AS
BEGIN
	
	Declare @Ret nvarchar(150) = ''

	if isnull(@OG_ID,0) != 0
	begin
		select @Ret = [Name] FROM [POMS_DB].[dbo].[T_Order_Group_List] ogl with (nolock) where ogl.OG_ID = @OG_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
