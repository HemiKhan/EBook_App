USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Process_File_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Process_File_IU]
	@FileName nvarchar(36)
	,@OriginalFileName nvarchar(1000)
	,@FileExt nvarchar(10)
	,@Path_ nvarchar(1000)
	,@Username nvarchar(150)
	,@Return_Code bit output
	,@Return_Text nvarchar(1000) output
	,@Error_Text nvarchar(max) output
AS
BEGIN
	
	Begin Try

		insert into [POMS_DB].[dbo].[T_Order_Process_Files] ([FileName],[OriginalFileName],[FileExt],[Path_],[AddedBy])
		values (@FileName ,@OriginalFileName ,@FileExt ,@Path_ ,@Username )

		set @Return_Code = 1
		set @Return_Text = 'Done'
		set @Error_Text = ''

	end try
	begin catch
		set @Return_Code = 0
		set @Return_Text = 'Internal Server Error'
		if @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @Error_Text = ERROR_MESSAGE()
	end catch

END
GO
