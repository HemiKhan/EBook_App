USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_UserName_DropDown_AutoComplete]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		-- exec [P_UserName_DropDown_AutoComplete] 'MUSA'
CREATE PROCEDURE [dbo].[P_UserName_DropDown_AutoComplete] -- 'testing  +'%''
 -- Add the parameters for the stored procedure here
@SearchText nvarchar(50)

As
Begin

 select [USER_ID], [USERNAME]  FROM T_Users WHERE [USERNAME] like '%'+ UPPER(@SearchText) +'%' 
 
End
GO
