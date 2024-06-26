USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_T_UserToSeller_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[F_Get_T_UserToSeller_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
	UTSM_ID int
    ,UserName nvarchar(150)
	,SELLER_KEY nvarchar(36)
	,SELLER_ID int
	,IsViewOrder bit
	,IsCreateOrder bit
	,IsGetQuote bit
	,IsFinancial bit
	,IsAdmin bit
	,IsBlankSubSellerAllowed bit
	,IsAllSubSellerAllowed bit
	,IsBlankPartnerAllowed bit
	,IsAllPartnerAllowed bit
	,IsBlankTariffAllowed bit
	,IsAllTariffAllowed bit
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
    SELECT UTSM_ID 
		,UserName = upper(UserName)
		,SELLER_KEY
		,SELLER_ID=isnull((SELECT top 1 [SELLER_ID] FROM [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) where sl.SELLER_KEY = s.SELLER_KEY),'')
		,IsViewOrder 
		,IsCreateOrder 
		,IsGetQuote 
		,IsFinancial 
		,IsAdmin 
		,IsBlankSubSellerAllowed 
		,IsAllSubSellerAllowed 
		,IsBlankPartnerAllowed 
		,IsAllPartnerAllowed 
		,IsBlankTariffAllowed 
		,IsAllTariffAllowed 
		,IsActive 
    FROM OPENJSON(@Json)
	with (
		UTSM_ID INT '$.UTSM_ID' ,
		UserName NVARCHAR(150) '$.UserName',
		SELLER_KEY nvarchar(36) '$.SELLER_KEY',
		IsViewOrder BIT '$.IsViewOrder',
		IsCreateOrder BIT '$.IsCreateOrder',
		IsGetQuote BIT '$.IsGetQuote',
		IsFinancial BIT '$.IsFinancial',
		IsAdmin BIT '$.IsAdmin',
		IsBlankSubSellerAllowed BIT '$.IsBlankSubSellerAllowed',
		IsAllSubSellerAllowed BIT '$.IsAllSubSellerAllowed',
		IsBlankPartnerAllowed BIT '$.IsBlankPartnerAllowed',
		IsAllPartnerAllowed BIT '$.IsAllPartnerAllowed',
		IsBlankTariffAllowed BIT '$.IsBlankTariffAllowed',
		IsAllTariffAllowed BIT '$.IsAllTariffAllowed',
		IsActive BIT '$.IsActive'
	) s

    RETURN;
END
GO
