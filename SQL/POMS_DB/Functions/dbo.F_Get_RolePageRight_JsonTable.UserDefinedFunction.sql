USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RolePageRight_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[F_Get_RolePageRight_JsonTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
RPRM_ID INT,
R_ID INT,
PR_ID INT,
IsRightActive INT,
Active INT
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
	SELECT RPRM_ID, R_ID, PR_ID, IsRightActive, Active FROM OpenJson(@Json)
	WITH (
		RPRM_ID INT '$.RPRM_ID',
		R_ID INT '$.R_ID',
		PR_ID INT '$.PR_ID',
		IsRightActive BIT '$.IsRightActive', 
		Active BIT '$.Active'
	) mch

	return

END
GO
