USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Set_Order_SearchType]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Set_Order_SearchType]  
(
	@OldValue nvarchar(1000)
	,@NewValue nvarchar(1000)
	,@CODE nvarchar(50)
	,@SearchType nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	
	Declare @Ret nvarchar(max) = ''
	set @SearchType = isnull(@SearchType,'')
	set @CODE = upper(isnull(@CODE,''))
	set @OldValue = isnull(@OldValue,'')
	set @OldValue = ltrim(rtrim(@OldValue))
	set @NewValue = isnull(@NewValue,'')
	set @NewValue = ltrim(rtrim(@NewValue))

	SET @Ret = (CASE WHEN @OldValue = @NewValue THEN @SearchType ELSE 
		(CASE WHEN @SearchType = '' THEN @CODE ELSE @SearchType + ',' + @CODE END) 
		END)

	set @Ret = isnull(@Ret,'')

	return @Ret
END
GO
