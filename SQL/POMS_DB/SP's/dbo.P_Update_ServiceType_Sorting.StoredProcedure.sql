USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Update_ServiceType_Sorting]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [P_Update_ServiceType_Sorting] '[{"New_Sort_Value":"1","Sort_ID":"125100","Sort_Text":"Drop-off at Metro FM Terminal","Old_Sort_Value":"0"},{"New_Sort_Value":"2","Sort_ID":"125100","Sort_Text":"Business with a Dock","Old_Sort_Value":"1"},{"New_Sort_Value":"3","Sort_ID":"125100","Sort_Text":"Business without a Dock","Old_Sort_Value":"2"},{"New_Sort_Value":"4","Sort_ID":"125100","Sort_Text":"Residential/ Non-Commercial","Old_Sort_Value":"3"}]','HAMMAS.KHAN'
CREATE PROC [dbo].[P_Update_ServiceType_Sorting]
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
	INNER JOIN [POMS_DB].[dbo].T_Service_Type st WITH (NOLOCK) ON s.Sort_ID = st.ST_CODE
	WHERE s.New_Sort_Value <> st.Sort_
	
	
	IF EXISTS (SELECT 1 FROM #Sorting_Temp WITH (NOLOCK))
	BEGIN	
		UPDATE [POMS_DB].[dbo].T_Service_Type
		SET Sort_ = t.New_Sort_Value 
		FROM #Sorting_Temp t WHERE ST_CODE = t.Sort_ID		
		SET @Return_Text = 'Service Type Sorting UPDATED Successfully!'
		SET @Return_Code = 1	
	END
	ELSE BEGIN
		SET @Return_Text = 'Data Already Sorted'
		SET @Return_Code = 0
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
