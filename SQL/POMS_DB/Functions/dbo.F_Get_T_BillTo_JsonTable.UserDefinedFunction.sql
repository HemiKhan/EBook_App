USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_T_BillTo_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[F_Get_T_BillTo_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    USTSBM_ID INT,
	UserName NVARCHAR(150),
	SBM_ID INT,
    IsViewOrder BIT,
    IsCreateOrder BIT,
    IsGetQuote BIT,
    IsFinancial BIT,
	IsActive BIT
)
AS
BEGIN
    SET @Json = ISNULL(@Json, '');

    IF @Json = ''
    BEGIN
        RETURN;
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
            RETURN;
        END
    END;
    
    INSERT INTO @ReturnTable (USTSBM_ID,UserName,SBM_ID,IsViewOrder, IsCreateOrder, IsGetQuote, IsFinancial,IsActive)
    SELECT 
		USTSBM_ID,
		UserName,
		SBM_ID,
        CAST(IsViewOrder AS BIT),
        CAST(IsCreateOrder AS BIT),
        CAST(IsGetQuote AS BIT),
        CAST(IsFinancial AS BIT),
		CAST(IsActive AS BIT)
    FROM OPENJSON(@Json)
    WITH (
	    USTSBM_ID int '$.USTSBM_ID',
		UserName nvarchar '$.UserName',
		SBM_ID int '$.SBM_ID',
        IsViewOrder BIT '$.isViewOrder',
        IsCreateOrder BIT '$.isCreateOrder',
        IsGetQuote BIT '$.isGetQuote',
        IsFinancial BIT '$.isFinancial',
		IsActive BIT '$.isActive'

    );

    RETURN;
END;
GO
