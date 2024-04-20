USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TimeName_From_And_To_Time]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create FUNCTION [dbo].[F_Get_TimeName_From_And_To_Time]
(	
	@FromTime time(7)
	,@ToTime time(7)
)
RETURNS nvarchar(50)

AS
begin
	
	Declare @TimeName nvarchar(50) = ''
	Declare @FromName nvarchar(50) = ''
	Declare @ToName nvarchar(50) = ''

	if (@FromTime is not null)
	begin
		set @FromName = format(cast(@FromTime as datetime),'hh:mm tt')
	end
	
	if (@ToTime is not null)
	begin
		set @ToName = format(cast(@ToTime as datetime),'hh:mm tt')
	end
	
	if (@FromName <> '' and @ToName <> '' and @FromName <> @ToName)
	begin
		set @TimeName = @FromName + ' To ' + @ToName
	end

	return @TimeName

end
GO
