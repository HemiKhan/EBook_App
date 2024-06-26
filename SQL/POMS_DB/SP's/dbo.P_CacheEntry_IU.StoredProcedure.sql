USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_CacheEntry_IU]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_CacheEntry_IU]
    @cacheKey VARCHAR(800),
	@applicationID int,
    @cacheValue NVARCHAR(MAX),
    @expirationTime DATETIME2
AS
BEGIN
    MERGE INTO [dbo].[T_CacheEntries] AS target
    USING (VALUES (@cacheKey, @applicationID, @cacheValue, @expirationTime)) AS source ([Key], ApplicationID, [Value], ExpiredOn)
    ON target.[Key] = source.[Key] and target.ApplicationID = source.ApplicationID
    WHEN MATCHED THEN
        UPDATE SET
            target.Value = source.Value,
            target.ExpiredOn = source.ExpiredOn
    WHEN NOT MATCHED THEN
        INSERT ([Key], ApplicationID, Value, ExpiredOn)
        VALUES (source.[Key], source.ApplicationID, source.Value, source.ExpiredOn);
END;
GO
