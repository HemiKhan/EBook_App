-- SELECT * FROM [dbo].[F_Get_AC_ID] ('','')
CREATE FUNCTION [dbo].[F_Get_AC_ID]
(	
	@ColumnName nvarchar(100),
	@TableName nvarchar(100)
)
RETURNS INT
AS
Begin
	DECLARE @AC_ID INT = 0
	SELECT @AC_ID = ISNULL(AC_ID,0) FROM [dbo].[T_Audit_Column] WHERE TableName = @TableName AND [Name] = @ColumnName
	return @AC_ID
end