USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Nvarchar_From_Numeric]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
Create FUNCTION [dbo].[F_Get_Nvarchar_From_Numeric]  
(
	@Value Float
)
RETURNS nvarchar(100)
AS
BEGIN
	
	Declare @Ret nvarchar(100) = ''
	select @Ret = (case when @Value is null then '' when @Value = 0 then '' else cast(@Value as nvarchar(100)) end)

	return @ret
END
GO
