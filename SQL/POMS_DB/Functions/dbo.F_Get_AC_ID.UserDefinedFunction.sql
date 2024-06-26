USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_AC_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_AC_ID]  
(
	@ColumnName nvarchar(100)
	,@TableName nvarchar(150)
)
RETURNS int
AS
BEGIN
	
	Declare @Ret int = 0
	select @Ret = AC_ID from [POMS_DB].[dbo].[T_Audit_Column] with (nolock) where DbName = @ColumnName and TableName = @TableName
	set @Ret = isnull(@Ret,0)

	return @Ret
END
GO
