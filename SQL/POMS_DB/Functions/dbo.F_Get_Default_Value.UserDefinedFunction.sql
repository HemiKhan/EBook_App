USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Default_Value]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Default_Value] ('S100052',null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Default_Value]
(	
	@SellerCode nvarchar(20)
	,@CONFIG_TYPE nvarchar(50)
)
RETURNS @ReturnTable TABLE 
(SELLER_KEY nvarchar(36), CONFIG_TYPE nvarchar(50), Description_ nvarchar(1000), REFNO1 nvarchar(50), REFNO2 nvarchar(50), REFNO3 nvarchar(50)
, REFID1 int, REFID2 int, REFID3 int, IsActive bit)
AS
begin
	
	set @SellerCode = isnull(@SellerCode,'')

	insert into @ReturnTable
	select * from (
		select SELLER_CODE=isnull(cdvs.SELLER_CODE,@SellerCode)
		, CONFIG_TYPE=dvs.CONFIG_TYPE
		, Description_=isnull(cdvs.Description_,dvs.Description_)
		, REFNO1=isnull(cdvs.REFNO1,dvs.REFNO1)
		, REFNO2=isnull(cdvs.REFNO2,dvs.REFNO2)
		, REFNO3=isnull(cdvs.REFNO3,dvs.REFNO3)
		, REFID1=isnull(cdvs.REFID1,dvs.REFID1)
		, REFID2=isnull(cdvs.REFID2,dvs.REFID2)
		, REFID3=isnull(cdvs.REFID3,dvs.REFID3)
		, IsActive=isnull(cdvs.IsActive,dvs.IsActive)
		from [POMS_DB].[dbo].[T_Default_Value_Setup] dvs with (nolock) 
		left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs with (nolock) on dvs.CONFIG_TYPE = cdvs.CONFIG_TYPE
		where (cdvs.SELLER_CODE = @SellerCode or cdvs.SELLER_CODE is null) 
		and ((dvs.CONFIG_TYPE = @CONFIG_TYPE and @CONFIG_TYPE is not null) or @CONFIG_TYPE is null)
	) ilv where ilv.IsActive = 1

	return
	

end
GO
