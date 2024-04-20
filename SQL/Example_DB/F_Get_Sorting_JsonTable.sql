
--	SELECT * FROM [dbo].[F_Get_Sorting_JsonTable]('')
CREATE FUNCTION [dbo].[F_Get_Sorting_JsonTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
New_Sort_Value INT,
Sort_ID NVARCHAR(50),
Sort_Text NVARCHAR(100),
Old_Sort_Value INT
)
AS
BEGIN
	
	SET @Json = ISNULL(@Json,'')

	IF @Json = ''
	BEGIN
		return
	END
	ELSE
	BEGIN
		IF ISJSON(@Json) = 0
		BEGIN
			return
		END
	END
	
	INSERT INTO @ReturnTable
	SELECT New_Sort_Value, Sort_ID, Sort_Text, Old_Sort_Value FROM OpenJson(@Json)
	WITH (
		New_Sort_Value int '$.New_Sort_Value',
		Sort_ID nvarchar(50) '$.Sort_ID',
		Sort_Text nvarchar(100) '$.Sort_Text',
		Old_Sort_Value int '$.Old_Sort_Value' 
	) mch

	return

END
GO
