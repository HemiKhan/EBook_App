USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Create_User_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[F_Get_Create_User_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    UserDetails NVARCHAR(max),
    UserSeller NVARCHAR(max)
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
        UserDetails, 
        UserSeller
    FROM OPENJSON(@Json)
    WITH (
        UserDetails NVARCHAR(max) '$.UserDetails' as json,
        UserSeller NVARCHAR(max) '$.UserSeller' as json
    );

    RETURN;
END
GO
