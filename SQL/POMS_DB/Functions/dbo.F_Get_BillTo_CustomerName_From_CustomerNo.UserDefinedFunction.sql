USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_BillTo_CustomerName_From_CustomerNo]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_BillTo_CustomerName_From_CustomerNo]  
(
	@BillTo_CustomerNo nvarchar(20)
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@BillTo_CustomerNo,'') != ''
	begin
		select @Ret = [Name] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where No_ = @BillTo_CustomerNo
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
