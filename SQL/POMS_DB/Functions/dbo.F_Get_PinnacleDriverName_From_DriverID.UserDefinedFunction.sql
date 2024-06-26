USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleDriverName_From_DriverID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleDriverName_From_DriverID]  
(
	@DriverID int
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''
	
	if isnull(@DriverID,0) != 0
	begin
		select @Ret = d.[Name] from [PinnacleProd].[dbo].[Metropolitan$Driver] d with (nolock) where d.[Driver Id] = @DriverID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
