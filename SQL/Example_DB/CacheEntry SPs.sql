CREATE OR ALTER PROCEDURE [dbo].[P_CacheEntry_IU]
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
END
GO

CREATE OR ALTER PROCEDURE [dbo].[P_CacheEntry_Delete]
    @cacheKey VARCHAR(800)
	,@applicationID int
AS
BEGIN
    
	if exists(select * from [dbo].[T_CacheEntries] with (nolock) where [Key] = @cacheKey and ApplicationID = @applicationID)
	begin
		Delete from [dbo].[T_CacheEntries] where [Key] = @cacheKey and ApplicationID = @applicationID
	end

END
GO

CREATE OR ALTER PROCEDURE [dbo].[P_Get_CacheEntry]
    @cacheKey VARCHAR(800),
	@applicationID int
AS
BEGIN    
	select [Key],[Value],[CreatedOn],[ExpiredOn] from [dbo].[T_CacheEntries] with (nolock) where [Key] = @cacheKey and ApplicationID = @applicationID
END