USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskAssignedToMap]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_AddOrEdit_TaskAssignedToMap]
    @TATM_ID INT = NULL,
    @TD_ID INT,
    @AssignedTo NVARCHAR(max),
	@AssignToType_MTV_CODE NVARCHAR(40),
    @Active BIT = 1,
    @Username NVARCHAR(150),
    @IPAddress NVARCHAR(20) = ''
AS
BEGIN
    DECLARE @Return_Code BIT = 1
    DECLARE @Return_Text NVARCHAR(1000) = ''

    DECLARE @AssignedToTable TABLE (ID INT IDENTITY(1,1), AssignedTo NVARCHAR(100))
    INSERT INTO @AssignedToTable
    SELECT value FROM STRING_SPLIT(@AssignedTo, ',')

    DECLARE @AddEditUpdateAssigneToTable TABLE (
        AssigneID INT IDENTITY(1,1),
        TempTATMID INT,
        TempTDID INT,
        TempAssigneTo NVARCHAR(max),
        TempActive BIT,
        EntreeType NVARCHAR(50)
    )

    INSERT INTO @AddEditUpdateAssigneToTable (TempTATMID, TempTDID, TempAssigneTo, TempActive, EntreeType)
    SELECT tam.TATM_ID, tam.TD_ID, tam.AssignedTo, 1, 'update' AS EntreeType 
    FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tam 
    INNER JOIN @AssignedToTable a ON tam.AssignedTo = a.AssignedTo
    WHERE tam.TD_ID = @TD_ID AND tam.IsActive = 0 
    UNION ALL
    SELECT tam.TATM_ID, tam.TD_ID, tam.AssignedTo, 0, 'remove'
    FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tam
    WHERE tam.TD_ID = @TD_ID  AND tam.IsActive = 1 AND tam.AssignedTo NOT IN (SELECT AssignedTo FROM @AssignedToTable)
    UNION ALL
    SELECT NULL, @TD_ID, a.AssignedTo, 1, 'add'
    FROM @AssignedToTable a
    WHERE a.AssignedTo NOT IN (SELECT ta.AssignedTo FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] ta WHERE ta.TD_ID = @TD_ID)

    IF EXISTS (SELECT 1 FROM @AddEditUpdateAssigneToTable WHERE EntreeType = 'add')
    BEGIN
        INSERT INTO [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] (TD_ID, AssignedTo,AssignToType_MTV_CODE, IsActive, AddedBy, AddedOn)
        SELECT an.TempTDID, TempAssigneTo, @AssignToType_MTV_CODE,TempActive, @Username, GETUTCDATE()
        FROM @AddEditUpdateAssigneToTable an
        WHERE an.EntreeType = 'add'

        SET @Return_Text = CONCAT(@Return_Text, '_Add')
        SET @Return_Code = 1
    END

    IF EXISTS (SELECT 1 FROM @AddEditUpdateAssigneToTable WHERE EntreeType IN ('remove', 'update'))
    BEGIN
        UPDATE ar
        SET ar.IsActive = RemoveData.TempActive,
		    ar.AssignToType_MTV_CODE=@AssignToType_MTV_CODE,
            ar.ModifiedBy = @Username, 
            ar.ModifiedOn = GETUTCDATE()
        FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] AS ar
        INNER JOIN (
            SELECT TempTATMID, TempActive
            FROM @AddEditUpdateAssigneToTable
            WHERE EntreeType IN ('remove', 'update')
        ) AS RemoveData ON ar.TATM_ID = RemoveData.TempTATMID

        SET @Return_Text = CONCAT(@Return_Text, '_Updated')
        SET @Return_Code = 1
    END

    SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code
END

 
GO
