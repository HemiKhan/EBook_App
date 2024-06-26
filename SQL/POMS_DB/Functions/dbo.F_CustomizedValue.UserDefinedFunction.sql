USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_CustomizedValue]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =========================================================================
-- ==========================================================================

CREATE FUNCTION [dbo].[F_CustomizedValue]
(
	@CustomerNo nvarchar(20),
	@Key nvarchar(100)
)
RETURNS nvarchar(max)

AS

BEGIN

	Declare @Ret nvarchar(max) = ''

	Declare @ASNCustomerNo nvarchar(20) = ''
	select @ASNCustomerNo = bi.[Customer No_] from [MetroPolitanNavProduction].[dbo].[Metropolitan$ASN Billing Info] bi with (nolock) where bi.[Billing Customer No] = @CustomerNo
	set @ASNCustomerNo = isnull(@ASNCustomerNo,'0')

	select top 1 @Ret = upper([Value]) from (
		select [CustomerNo], [Name], [Value]
		, [Priority] = case [CustomerNo] when @CustomerNo then 1 when '0' then 3 else 2 end -- Priority 1 to Customer, 2 to Group/Umbrella, 3 to default
		from [PinnacleProd].[dbo].[Metro_CustomerCustomizations] cc with (nolock)
		where cc.[CustomerNo] in (@CustomerNo,@ASNCustomerNo,'0') and cc.[Name] = @Key 
	) t order by t.[Priority] asc, t.[CustomerNo] desc

	set @Ret = isnull(@Ret,0)

	return @Ret

END
GO
