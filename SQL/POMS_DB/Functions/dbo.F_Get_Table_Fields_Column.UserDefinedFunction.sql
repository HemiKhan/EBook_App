USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Fields_Column]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [dbo].[F_Get_Table_Fields_Column] ('')
-- =============================================
create FUNCTION [dbo].[F_Get_Table_Fields_Column]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,[Name] nvarchar(150)
,IsColumnRequired bit
)
AS
Begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end

	insert into @ReturnTable (Code ,[Name] ,IsColumnRequired)
	select distinct * from (
		select Code = isnull(ret.Code,'')
		,[Name] = isnull(ret.[Name],'')
		,IsColumnRequired = isnull(ret.IsColumnRequired,0)

		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,[Name] nvarchar(1000) '$.Name'
			,IsColumnRequired bit '$.IsColumnRequired'
		) ret
	) ilv where Code <> '' and IsColumnRequired = 0
	
	return

end
GO
