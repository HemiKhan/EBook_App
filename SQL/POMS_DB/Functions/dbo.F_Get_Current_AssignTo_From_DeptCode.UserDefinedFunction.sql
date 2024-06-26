USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Current_AssignTo_From_DeptCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[F_Get_Current_AssignTo_From_DeptCode]
(
	@CurrentAssignToDept_MTV_CODE nvarchar(20)
	,@OEDAssignTo nvarchar(150)
	,@CSRAssignTo nvarchar(150)
	,@DispatchAssignTo nvarchar(150)
	,@AccountAssignTo nvarchar(150)
)
RETURNS nvarchar(150)
AS
BEGIN
	DECLARE @Ret nvarchar(150) = null

	if @CurrentAssignToDept_MTV_CODE = 'OED'
	begin
		set @Ret = @OEDAssignTo
	end
	else if @CurrentAssignToDept_MTV_CODE = 'CSR'
	begin
		set @Ret = @CSRAssignTo
	end
	else if @CurrentAssignToDept_MTV_CODE = 'DISPATCH'
	begin
		set @Ret = @DispatchAssignTo
	end
	else if @CurrentAssignToDept_MTV_CODE = 'ACCOUNT'
	begin
		set @Ret = @AccountAssignTo
	end

	return @Ret

end

GO
