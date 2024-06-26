USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Update_Page_Sorting]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--							EXEC [P_Update_PageGroup_Sorting] '[{"New_Sort_Value":1,"Sort_ID":1,"Sort_Text":"General","Old_Sort_Value":1},{"New_Sort_Value":2,"Sort_ID":2,"Sort_Text":"Home","Old_Sort_Value":2},{"New_Sort_Value":3,"Sort_ID":3,"Sort_Text":"Medical Claim","Old_Sort_Value":3},{"New_Sort_Value":4,"Sort_ID":5,"Sort_Text":"Reports","Old_Sort_Value":4},{"New_Sort_Value":5,"Sort_ID":4,"Sort_Text":"Security","Old_Sort_Value":5}]','HAMMAS.KHAN'
create PROC [dbo].[P_Update_Page_Sorting]
@Json nvarchar(max),
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

	IF OBJECT_ID('tempdb..#Sorting_Temp') IS NOT NULL BEGIN DROP TABLE #Sorting_Temp END
	SELECT New_Sort_Value,Sort_ID,Sort_Text,Old_Sort_Value 
	INTO #Sorting_Temp from [dbo].[F_Get_Sorting_JsonTable] (@Json) s
	INNER JOIN [POMS_DB].[dbo].T_Page p WITH (NOLOCK) ON s.Sort_ID = p.P_ID
	WHERE s.New_Sort_Value <> p.Sort_
	
	
	IF EXISTS (SELECT 1 FROM #Sorting_Temp WITH (NOLOCK))
	BEGIN	
		UPDATE [POMS_DB].[dbo].T_Page
		SET Sort_ = t.New_Sort_Value 
		FROM #Sorting_Temp t WHERE P_ID = t.Sort_ID		
		SET @Return_Text = 'Page Sorting UPDATED Successfully!'
		SET @Return_Code = 1	
	END
	ELSE BEGIN
		SET @Return_Text = 'Data Already Sorted'
		SET @Return_Code = 0
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
