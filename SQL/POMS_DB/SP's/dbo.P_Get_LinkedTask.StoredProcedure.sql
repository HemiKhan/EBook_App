USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_LinkedTask]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

-- exec P_Get_LinkedTask 101
CREATE PROCEDURE [dbo].[P_Get_LinkedTask] 
    @Parent_TD INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CASE 
            WHEN Parent_TD = @Parent_TD THEN Parent_TD
            ELSE LinkedTask_TD
        END AS Parent_TD,
        CASE 
            WHEN Parent_TD = @Parent_TD THEN LinkedTask_TD
            ELSE Parent_TD
        END AS LinkedTask_TD
    FROM 
        [POMS_DB].[dbo].[T_TMS_LinkedTasks] WITH (NOLOCK)
    WHERE 
        IsActive = 1 
        AND (@Parent_TD IN (Parent_TD, LinkedTask_TD) OR LinkedTask_TD = @Parent_TD);
END;
GO
