USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_T_UserSellerToSubSeller_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[F_Get_T_UserSellerToSubSeller_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
	USTSSM_ID int
	,UserName nvarchar(150)
	,SSM_ID int
	,IsViewOrder bit
	,IsCreateOrder bit
	,IsGetQuote bit
	,IsFinancial bit
	,IsActive bit
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
    SELECT USTSSM_ID 
		,UserName = upper(UserName)
		,SSM_ID 
		,IsViewOrder 
		,IsCreateOrder 
		,IsGetQuote 
		,IsFinancial 
		,IsActive 
    FROM OPENJSON(@Json)
	with( 
		USTSSM_ID INT '$.USTSSM_ID' ,
		UserName NVARCHAR(150) '$.UserName',
		SSM_ID INT '$.SSM_ID',
		IsViewOrder BIT '$.IsViewOrder',
		IsCreateOrder BIT '$.IsCreateOrder',
		IsGetQuote BIT '$.IsGetQuote',
		IsFinancial BIT '$.IsFinancial',
		IsActive BIT '$.IsActive'
	);

    RETURN;
END
GO
