--	SELECT * FROM [dbo].[F_Get_MTV_Name_By_CODE] ("11")
CREATE FUNCTION [dbo].[F_Get_MTV_Name_By_CODE]  
(
	@MTV_CODE nvarchar(20)
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@MTV_CODE,'') != ''
	begin
		select @Ret = [Name] from [dbo].[T_Master_Type_Value] with (nolock) where MTV_CODE = @MTV_CODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO