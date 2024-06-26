USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[p_GetAllDropdownData_UserSetup]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_GetAllDropdownData_UserSetup]
    @Seller_key nvarchar(40)
AS
BEGIN
    SELECT 'BillTo' AS DropdownType, sbm.[SBM_ID] AS Code, c.[Name]
    FROM [POMS_DB].[dbo].[T_Seller_BillTo_Mapping] sbm WITH (NOLOCK)
    INNER JOIN [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c WITH (NOLOCK) ON sbm.BillTo_CUSTOMER_KEY = CAST([Customer GUID] AS NVARCHAR(36))
    WHERE sbm.SELLER_KEY = @Seller_key AND [IsActive] = 1;

    SELECT 'Partner' AS DropdownType, spm.[SPM_ID] AS Code, spl.[company] AS [Name]
    FROM [POMS_DB].[dbo].[T_Seller_Partner_Mapping] spm WITH (NOLOCK)
    INNER JOIN [POMS_DB].[dbo].[T_Seller_Partner_List] spl WITH (NOLOCK) ON spm.SELLER_PARTNER_KEY = spl.SELLER_PARTNER_KEY
    WHERE spm.SELLER_KEY = @Seller_key AND spm.[IsActive] = 1;

    SELECT 'SubSeller' AS DropdownType, ssm.[SSM_ID] AS Code, subsl.[company] AS [Name]
    FROM [POMS_DB].[dbo].[T_Seller_SubSeller_Mapping] ssm WITH (NOLOCK)
    INNER JOIN [POMS_DB].[dbo].[T_SubSeller_List] subsl WITH (NOLOCK) ON subsl.SUB_SELLER_KEY = ssm.SUB_SELLER_KEY
    WHERE ssm.SELLER_KEY = @Seller_key AND ssm.[IsActive] = 1;

    SELECT 'Tariff' AS DropdownType, stm.[STM_ID] AS Code, stl.[Name]
    FROM [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] stm WITH (NOLOCK)
    INNER JOIN [POMS_DB].[dbo].[T_Tariff_List] stl WITH (NOLOCK) ON stm.TARIFF_NO = stl.TARIFF_NO
    WHERE stm.SELLER_KEY = @Seller_key AND stm.[IsActive] = 1;
END
GO
