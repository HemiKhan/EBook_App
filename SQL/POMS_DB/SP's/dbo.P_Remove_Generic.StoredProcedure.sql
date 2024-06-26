USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_Generic]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--		EXEC [dbo].[P_Remove_Generic] '','',1,'',''

create PROC [dbo].[P_Remove_Generic]
    @TableName NVARCHAR(150),
    @ColumnName NVARCHAR(150),
    @ColumnValue INT,
    @Username NVARCHAR(150),
    @IPAddress NVARCHAR(20) = ''
AS
BEGIN
    DECLARE @Return_Code BIT = 1;
    DECLARE @Return_Text NVARCHAR(1000) = '';

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName)
    BEGIN
        DECLARE @IsActive BIT;
        DECLARE @Sql NVARCHAR(MAX);

        SET @Sql = N'SELECT @IsActive = IsActive FROM ' + QUOTENAME(@TableName) + ' WHERE ' + QUOTENAME(@ColumnName) + ' = @ColumnValue;';

        EXEC sp_executesql @Sql, N'@ColumnValue INT, @IsActive BIT OUTPUT', @ColumnValue, @IsActive OUTPUT;

        IF @@ROWCOUNT > 0
        BEGIN
            IF @IsActive = 0
            BEGIN
                SET @Sql = N'UPDATE ' + QUOTENAME(@TableName) + ' SET IsActive = 1 WHERE ' + QUOTENAME(@ColumnName) + ' = @ColumnValue;';
                EXEC sp_executesql @Sql, N'@ColumnValue INT', @ColumnValue;
                SET @Return_Text = 'Record ACTIVE Successfully!';
                SET @Return_Code = 1;
            END
            ELSE
            BEGIN
                SET @Sql = N'UPDATE ' + QUOTENAME(@TableName) + ' SET IsActive = 0 WHERE ' + QUOTENAME(@ColumnName) + ' = @ColumnValue;';
                EXEC sp_executesql @Sql, N'@ColumnValue INT', @ColumnValue;
                SET @Return_Text = 'Record IN-ACTIVE Successfully!';
                SET @Return_Code = 1;
            END
        END
        ELSE
        BEGIN
            SET @Return_Text = 'Record with specified parm value does not exist!';
            SET @Return_Code = 0;
        END
    END
    ELSE
    BEGIN
        SET @Return_Text = 'Table does not exist!';
        SET @Return_Code = 0;
    END

    SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code;
END
GO
