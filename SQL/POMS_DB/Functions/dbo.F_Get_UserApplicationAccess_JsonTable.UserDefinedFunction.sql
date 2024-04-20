USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_UserApplicationAccess_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_Get_UserApplicationAccess_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    UAA_ID int, 
	USERNAME nvarchar(150), 
	Application_MTV_ID int, 
	NAV_USERNAME nvarchar(150), 
	IsActive bit
)
AS
BEGIN
    SET @Json = ISNULL(@Json, '')

    IF @Json = ''
    BEGIN
        RETURN
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
            RETURN
        END
    END
    
    INSERT INTO @ReturnTable
    SELECT 
        UAA_ID,
		USERNAME,
		Application_MTV_ID,
		NAV_USERNAME=(case when NAV_USERNAME = '' then null else NAV_USERNAME end),
		IsActive
    FROM OPENJSON(@Json)
    WITH (
        UAA_ID int '$.UAA_ID',
        USERNAME NVARCHAR(150) '$.USERNAME',
		Application_MTV_ID int '$.Application_MTV_ID',
		NAV_USERNAME NVARCHAR(150) '$.NAV_USERNAME',
		IsActive bit '$.IsActive'
    );

    RETURN;
END
GO
