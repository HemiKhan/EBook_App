USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitIntoTableWithSpace]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select * from [dbo].[SplitIntoTableWithSpace]('A B C  D ')

CREATE FUNCTION [dbo].[SplitIntoTableWithSpace]
(
	@List varchar(max)
)	
returns @ReturnTable table(ID int identity(1,1), Text_ nvarchar(1000))
as
begin
DECLARE @SplitOn varchar (5)
DECLARE @char varchar(1000)
Set @SplitOn = ' '

set @List = @List

	While (Charindex(@SplitOn,@List)>0)
	begin
		SET @char = ltrim(rtrim(Substring(@List,1,Charindex(@SplitOn,@List)-1)))
		SET @List = ltrim(rtrim(Substring(@List,Charindex(@SplitOn,@List)+len(@SplitOn),len(@List))))
		insert into @ReturnTable (Text_)
		select @char where @char<>''
	end 
	insert into @ReturnTable (Text_)
	select @List where @List<>''

return
end
GO
