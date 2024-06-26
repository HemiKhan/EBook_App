USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitText]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitText](@inputText NVARCHAR(MAX), @Spliter nvarchar(10) = ',')
RETURNS TABLE
AS
RETURN
(
    SELECT
        LEFT(@inputText, CASE WHEN CHARINDEX(@Spliter, @inputText) > 0 THEN CHARINDEX(@Spliter, @inputText) - 1 ELSE LEN(@inputText) END) AS Text1,
        CASE WHEN CHARINDEX(@Spliter, @inputText) > 0 THEN RIGHT(@inputText, LEN(@inputText) - CHARINDEX(@Spliter, @inputText)) END AS Text2
);
GO
