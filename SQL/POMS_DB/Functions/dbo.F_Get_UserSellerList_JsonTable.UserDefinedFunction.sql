USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_UserSellerList_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create FUNCTION [dbo].[F_Get_UserSellerList_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    UserToSellerJson NVARCHAR(max),
    BillToJson NVARCHAR(max),
	PartnerToJson NVARCHAR(max),
	SubSellerToJson NVARCHAR(max),
	TariffJson NVARCHAR(max)
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
        BillToJson,
		PartnerToJson,
		SubSellerToJson,
		TariffJson
    FROM OPENJSON(@Json)
    WITH (
        UserDetails NVARCHAR(max) '$.UserToSeller' as json,
        BillToJson NVARCHAR(max) '$.BillTo' as json,
		PartnerToJson NVARCHAR(max) '$.PartnerTo' as json,
		SubSellerToJson NVARCHAR(max) '$.SubSellerTo' as json,
		TariffJson NVARCHAR(max) '$.Tariff' as json
    );

    RETURN;
END
GO
