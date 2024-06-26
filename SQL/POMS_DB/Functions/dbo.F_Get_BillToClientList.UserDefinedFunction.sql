USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_BillToClientList]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_BillToClientList] ('8EB285F5-9C49-4F6A-AA7A-D7B1F67F38E6','PPLUS.NETRETAILER')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_BillToClientList]
(	
	@CustomerKey nvarchar(36)
	,@Username nvarchar(150)
)
RETURNS @CustomerTable TABLE 
(CustomerKey nvarchar(36), CustomerNo nvarchar(20), CustomerName nvarchar(250)
--Create table #CustomerTable (CustomerKey nvarchar(36), CustomerNo nvarchar(20), CustomerName nvarchar(150)
, PaymentTermsCode nvarchar(20), PaymentMethodCode nvarchar(20), DepartmentCode nvarchar(20))
AS
begin

	if @CustomerKey is not null and @Username is null
	begin
		insert into @CustomerTable (CustomerKey , CustomerNo , CustomerName , PaymentTermsCode , PaymentMethodCode , DepartmentCode)
		select cast([Customer GUID] as nvarchar(36)) as CustomerKey, [No_] as CustomerNo,[Name] as CustomerName,[Payment Terms Code] as [PaymentTermsCode]
		,[Payment Method Code] as [PaymentMethodCode],[Department Code] as [DepartmentCode]
		from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where Blocked in (0,2) and [Is Active] = 1 and cast([Customer GUID] as nvarchar(36)) = @CustomerKey
	end
	else
	begin
		Declare @UserType_MTV_CODE nvarchar(20) = ''
		if (@Username is not null)
		begin
			set @Username = upper(@Username)
			select @UserType_MTV_CODE = UserType_MTV_CODE
			from [POMS_DB].[dbo].[T_Users] with (nolock) where USERNAME = @Username
			set @UserType_MTV_CODE = isnull(@UserType_MTV_CODE,'')
		end
		if @UserType_MTV_CODE = ''
		begin
			insert into @CustomerTable (CustomerKey , CustomerNo , CustomerName , PaymentTermsCode , PaymentMethodCode , DepartmentCode)
			select cast([Customer GUID] as nvarchar(36)) as CustomerKey, [No_] as CustomerNo,[Name] as CustomerName,[Payment Terms Code] as [PaymentTermsCode]
			,[Payment Method Code] as [PaymentMethodCode],[Department Code] as [DepartmentCode]
			from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where 1 = 0
		end
		else if @UserType_MTV_CODE = 'CLIENT-USER'
		begin
			insert into @CustomerTable (CustomerKey , CustomerNo , CustomerName , PaymentTermsCode , PaymentMethodCode , DepartmentCode)
			select cast([Customer GUID] as nvarchar(36)) as CustomerKey, [No_] as CustomerNo,[Name] as CustomerName,[Payment Terms Code] as [PaymentTermsCode]
			,[Payment Method Code] as [PaymentMethodCode],[Department Code] as [DepartmentCode]
			from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where Blocked in (0,2) and [Is Active] = 1 
			and Blocked in (0,2) and [Is Active] = 1 
			and cast([Customer GUID] as nvarchar(36)) in (select sbm.BillTo_CUSTOMER_KEY collate Latin1_General_100_CS_AS from [POMS_DB].[dbo].[T_Seller_BillTo_Mapping] sbm with (nolock) 
				inner join [POMS_DB].[dbo].[T_User_Seller_To_BillTo_Mapping] ustbm with (nolock) on sbm.SBM_ID = ustbm.[SBM_ID] and sbm.IsActive = 1 and ustbm.IsActive = 1 
				where UserName = @Username)
			and (cast([Customer GUID] as nvarchar(36)) = isnull(@CustomerKey,'') or @CustomerKey is null)
			--and ((cast([Customer GUID] as nvarchar(36)) = @CustomerKey and @CustomerKey = @ClientCustomerNo) or (No_ = @ClientCustomerNo and @CustomerKey is null))
		end
		else if @UserType_MTV_CODE = 'METRO-USER'
		begin
			insert into @CustomerTable (CustomerKey , CustomerNo , CustomerName , PaymentTermsCode , PaymentMethodCode , DepartmentCode)
			select cast([Customer GUID] as nvarchar(36)) as CustomerKey, [No_] as CustomerNo,[Name] as CustomerName,[Payment Terms Code] as [PaymentTermsCode]
			,[Payment Method Code] as [PaymentMethodCode],[Department Code] as [DepartmentCode]
			from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where Blocked in (0,2) and [Is Active] = 1 
			and (cast([Customer GUID] as nvarchar(36)) = isnull(@CustomerKey,'') or @CustomerKey is null)
		end
	end

	return
	

end
GO
