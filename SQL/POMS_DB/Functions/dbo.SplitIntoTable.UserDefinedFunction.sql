USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitIntoTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from [dbo].SplitIntoTable('A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z')

Create FUNCTION [dbo].[SplitIntoTable]
(
	@List varchar(max)
)	
returns @t table(id nvarchar(50))
as
begin
DECLARE @SplitOn varchar (5)
DECLARE @char varchar(80)
Set @SplitOn = ','

set @List = @List + @SplitOn

	While (Charindex(@SplitOn,@List)>0)
	begin
		SET @char = ltrim(rtrim(Substring(@List,1,Charindex(@SplitOn,@List)-1)))
		SET @List = Substring(@List,Charindex(@SplitOn,@List)+len(@SplitOn),len(@List)) 
		insert into @t
		select @char
	end 

return
end
GO
