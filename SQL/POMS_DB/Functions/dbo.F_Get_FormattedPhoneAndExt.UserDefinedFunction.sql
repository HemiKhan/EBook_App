USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_FormattedPhoneAndExt]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_Get_FormattedPhoneAndExt]
(
	@pPhoneNo varchar(50)
)
RETURNS @tRet TABLE 
(
	RawPhoneNo varchar(50), 
	PhoneNo varchar(50), 
	Extension varchar(50), 
	FormattedPhoneNo varchar(50), 
	FormattedExtension varchar(50)
)
AS
BEGIN
	declare @pos int = charindex('-', @pPhoneNo), @phone varchar(50) = @pPhoneNo, @ext varchar(50) = ''
	if (@pos > 0)
	set @phone = ltrim(rtrim(substring(@pPhoneNo, 1, (@pos - 1))))
if (len(@pPhoneNo) > @pos and @pos > 0)
	set @ext = ltrim(rtrim(substring(@pPhoneNo, @pos + 1, 7)))

insert into @tRet (RawPhoneNo, PhoneNo, Extension, FormattedPhoneNo, FormattedExtension)
select	RawPhoneNo = @pPhoneNo
			, PhoneNo = @phone
			, Extension = @ext
			, FormattedPhoneNo = case 
					when len(@phone) > 0 then '(' + substring(@phone, 1, 3) + ') ' 
						+ case 
							when len(@phone) > 3 then substring(@phone, 4, 3) 
								+ case when len(@phone) > 6 then '-' + substring(@phone, 7, 15) else '' end
							else '' 
						end
					else '' 
				end
			, FormattedExtension = case when len(@ext) > 0 then ' Ext-' + @ext else ' Ext-' end

return

end
GO
