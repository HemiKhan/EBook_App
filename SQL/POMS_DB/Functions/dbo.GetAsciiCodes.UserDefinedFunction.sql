USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAsciiCodes]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAsciiCodes] (@InputString NVARCHAR(MAX)) RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX) = '';
    DECLARE @Index INT = 1;

    WHILE @Index <= LEN(@InputString)
    BEGIN
        SET @Result = @Result + ' ' + CAST(ASCII(SUBSTRING(@InputString, @Index, 1)) AS NVARCHAR);
        SET @Index = @Index + 1;
    END

    RETURN LTRIM(@Result);
END;
GO
