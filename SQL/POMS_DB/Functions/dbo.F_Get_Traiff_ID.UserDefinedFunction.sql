USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Traiff_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--	select [dbo].[F_Get_Traiff_ID] (100004)
CREATE FUNCTION [dbo].[F_Get_Traiff_ID]
(
    @Val INT
)
RETURNS VARCHAR(11)
AS
BEGIN
    DECLARE @Result VARCHAR(11) = ''

    IF (@Val <= 0)
    BEGIN
        RETURN '0'
    END

    WHILE (@Val > 0)
    BEGIN
        SELECT @Result = CHAR(@Val % 36 + CASE WHEN @Val % 36 < 10 THEN 48 ELSE 55 END) + @Result,
               @Val = FLOOR(@Val/36)
    END

    RETURN @Result
END
GO
