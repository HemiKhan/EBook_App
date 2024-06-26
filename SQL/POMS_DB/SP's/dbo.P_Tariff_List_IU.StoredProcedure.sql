USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Tariff_List_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Tariff_List_IU] @Tariff_ID = 0 ,@Name = 'Testing' ,@Description = 'Testing' ,@IsActive = 1 ,@Username = 'ABDULLAH.ARSHAD'
-- =============================================
CREATE PROCEDURE [dbo].[P_Tariff_List_IU]  
	@Tariff_ID int
	,@Name nvarchar(150)
	,@Description nvarchar(250)
	,@IsActive bit
	,@Username nvarchar(150)
AS
BEGIN

	DECLARE @Tariff_NO nvarchar(100) = ''
	DECLARE @Tariff_Hash nvarchar(13) = ''
	Declare @Return_Code bit = 0
	Declare @Return_Text nvarchar(500) = ''
	
	begin try
		if @Tariff_ID = 0
		begin
			exec [POMS_DB].[dbo].[P_Generate_TariffID] @Ret_TariffID = @Tariff_ID out
			select @Tariff_Hash=[POMS_DB].[dbo].[F_Get_Traiff_ID] (@Tariff_ID)
			select @Tariff_NO=CONVERT(varchar(12), right(newid(),12))
			select @Tariff_NO=right(@Tariff_NO + @Tariff_Hash,12)
			set @Tariff_NO=Stuff(@Tariff_NO, Len(@Tariff_NO)-5, 0, '-')
			set @Tariff_NO = isnull(@Tariff_NO,'')
		
			if @Tariff_NO <> ''
			begin
				--insert into [POMS_DB].[dbo].[T_Tariff_List] ([TARIFF_ID] ,[TARIFF_NO] ,[Name] ,[Description] ,[IsActive] ,[AddedBy])
				--values (@Tariff_ID,@Tariff_NO,@Name,@Description,@IsActive,@Username)
				set @Return_Code = 1
				set @Return_Text = 'Inserted'
			end
			else
			begin
				set @Return_Code = 1
				set @Return_Text = 'Unable to Generate Tariff ID'
			end
		end
		else
		begin
			update [POMS_DB].[dbo].[T_Tariff_List] 
			set [Name] = @Name 
			,[Description] = @Description 
			,[IsActive] = @IsActive
			,[ModifiedBy] = @Username
			,[ModifiedOn] = getutcdate()
			where [Tariff_No] = @Tariff_No
			set @Return_Code = 1
			set @Return_Text = 'Updated'
		end

	end try
	
	begin catch
		select ERROR_MESSAGE()
		set @Tariff_ID = 0
		set @Tariff_NO = 'Error'
	end catch
	
	select @Tariff_ID Tariff_ID,@Tariff_NO Tariff_NO
END
GO
