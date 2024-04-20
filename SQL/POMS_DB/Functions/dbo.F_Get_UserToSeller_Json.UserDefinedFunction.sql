USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_UserToSeller_Json]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select [dbo].[F_Get_UserToSeller_Json] ('IHTISHAMTETS')

CREATE FUNCTION [dbo].[F_Get_UserToSeller_Json]
(	
	@UserName nvarchar(300)
	 
)
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	select @Return_Json =( select ( 
	
				   (SELECT
						usts.UTSM_ID,
						usts.UserName,
						sl.SELLER_KEY,
						sl.ContactPerson As [Name],
						usts.IsViewOrder,
						usts.IsCreateOrder,
						usts.IsGetQuote,
						usts.IsFinancial,
						usts.IsAdmin,
						usts.IsBlankSubSellerAllowed,
						usts.IsAllSubSellerAllowed,
						usts.IsBlankPartnerAllowed,
						usts.IsAllPartnerAllowed,
						usts.IsBlankTariffAllowed,
						usts.IsAllTariffAllowed,
						usts.IsActive,
						--BillTO
						( SELECT
								ustb.USTSBM_ID,
								ustb.UserName,
								ustb.SBM_ID,
								ustb.IsViewOrder,
								ustb.IsCreateOrder,
								ustb.IsGetQuote,
								ustb.IsFinancial,
								ustb.IsActive,
								sbm.SELLER_KEY,
								c.[Name]
							FROM
								[POMS_DB].[dbo].[T_User_Seller_To_BillTo_Mapping] ustb WITH (NOLOCK)
								INNER JOIN [T_Seller_BillTo_Mapping] sbm WITH (NOLOCK) ON ustb.SBM_ID = sbm.SBM_ID
								INNER JOIN [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c WITH (NOLOCK) ON sbm.BillTo_CUSTOMER_KEY = CAST([Customer GUID] AS NVARCHAR(36))
							WHERE
								 ustb.UserName = @UserName
								AND 
								sbm.SELLER_KEY = sl.SELLER_KEY -- Ensure seller key match
							FOR JSON PATH ) As BillTo,
							----End BillTO

							----StarPartnerTO

							( SELECT
								ustpm.USTSPM_ID,
								ustpm.UserName,
								ustpm.SPM_ID,
								ustpm.IsViewOrder,
								ustpm.IsCreateOrder,
								ustpm.IsGetQuote,
								ustpm.IsFinancial,
								ustpm.IsActive,
								spm.SELLER_KEY,
								spl.[company] AS [Name]
								
							FROM
								[POMS_DB].[dbo].[T_User_Seller_To_Partner_Mapping] ustpm WITH (NOLOCK)
								INNER JOIN [POMS_DB].[dbo].[T_Seller_Partner_Mapping] spm WITH (NOLOCK) on ustpm.SPM_ID=spm.SPM_ID
							    INNER JOIN [POMS_DB].[dbo].[T_Seller_Partner_List] spl WITH (NOLOCK) ON spm.SELLER_PARTNER_KEY = spl.SELLER_PARTNER_KEY
								WHERE spm.SELLER_KEY = sl.SELLER_KEY 
								 AND ustpm.[IsActive] = 1
								 And ustpm.UserName = @UserName
								 
							FOR JSON PATH ) As PartnerTo,


							-- End PartnerTO

							--StarSubSeller
							( SELECT  
 									 ustsm.USTSSM_ID
 									,ustsm.UserName
 									,ustsm.SSM_ID
 									,ustsm.IsViewOrder
 									,ustsm.IsCreateOrder
 									,ustsm.IsGetQuote
 									,ustsm.IsFinancial
 									,ssm.SELLER_KEY
									,ssm.[SSM_ID] AS Code
									,subsl.[company] AS [Name]
			   
									From [POMS_DB].[dbo].[T_User_Seller_To_SubSeller_Mapping] ustsm  WITH (NOLOCK)
									INNER JOIN [POMS_DB].[dbo].[T_Seller_SubSeller_Mapping] ssm WITH (NOLOCK) on ustsm.SSM_ID=ssm.SSM_ID
									INNER JOIN [POMS_DB].[dbo].[T_SubSeller_List] subsl WITH (NOLOCK) ON subsl.SUB_SELLER_KEY = ssm.SUB_SELLER_KEY
									WHERE ustsm.UserName =@UserName
									And ssm.SELLER_KEY = sl.SELLER_KEY
									AND ustsm.IsActive = 1
									for json path ) As SubSellerTo,


									--Start TarifTo
									(SELECT 
										  usttm.USTSTM_ID
										 ,usttm.UserName
										 ,usttm.STM_ID
										 ,usttm.IsViewOrder
										 ,usttm.IsCreateOrder
										 ,usttm.IsGetQuote
										 ,usttm.IsFinancial
										 ,stm.SELLER_KEY
										  ,stl.[Name]
										FROM [POMS_DB].[dbo].[T_User_Seller_To_Tariff_Mapping] usttm WITH (NOLOCK) 
										INNER JOIN [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] stm WITH (NOLOCK) on usttm.STM_ID=stm.STM_ID
										INNER JOIN [POMS_DB].[dbo].[T_Tariff_List] stl WITH (NOLOCK) ON stm.TARIFF_NO = stl.TARIFF_NO
										WHERE 
										stm.SELLER_KEY =sl.SELLER_KEY 
										And usttm.UserName=@UserName
										AND usttm.IsActive = 1
										for json path
										) As Tariff
										 


					FROM
						[POMS_DB].[dbo].[T_User_To_Seller_Mapping] usts WITH (NOLOCK)
						INNER JOIN [POMS_DB].[dbo].[T_Seller_List] sl WITH (NOLOCK) ON usts.SELLER_ID = sl.SELLER_ID
					WHERE
					usts.UserName=@UserName
						--sl.SELLER_KEY ='0A8B8263-C9DE-4AFD-BCC6-8FAFD12C9E08' -- Ensure seller key match
					FOR JSON PATH  ) 
					
					) As UserToSeller)

	if @Return_Json is null	begin set @Return_Json = '' end

	return @Return_Json

end
GO
