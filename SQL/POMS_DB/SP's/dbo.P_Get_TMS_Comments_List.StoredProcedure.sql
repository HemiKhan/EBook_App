USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TMS_Comments_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--		EXEC [P_Get_TMS_Comments_List] 1, 'HAMMAS.KHAN'

CREATE PROCEDURE [dbo].[P_Get_TMS_Comments_List]
    @TD_ID INT,
	@Username nvarchar(150)
AS
BEGIN
    SET NOCOUNT ON;
	    
	SELECT 
		TC_ID, 
		TD_ID, 
		CommentBy = CONCAT(u.FirstName,' ',u.LastName), 
		ShortCommentBy = CONCAT(LEFT(u.FirstName,1),'',LEFT(u.LastName,1)), 
		CommentOn = FORMAT(tc.AddedOn,'dd-MMM-yy HH:mm:ss tt'),
		CommentAgo =
    CASE 
        WHEN DATEDIFF(SECOND, tc.AddedOn, GETUTCDate()) < 60 THEN 'Just Now'
        WHEN DATEDIFF(MINUTE, tc.AddedOn, GETUTCDate()) < 60 THEN CAST(DATEDIFF(MINUTE, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' min ago'
        WHEN DATEDIFF(HOUR, tc.AddedOn, GETUTCDate()) < 24 THEN CAST(DATEDIFF(HOUR, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' hour ago'
        WHEN DATEDIFF(DAY, tc.AddedOn, GETUTCDate()) < 30 THEN CAST(DATEDIFF(DAY, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' days ago'
        ELSE CAST(DATEDIFF(MONTH, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' month ago'
    END,
		MemeberActive = CASE WHEN tc.AddedBy = @Username THEN 1 ELSE 0 END,
		CommentText 
	FROM [POMS_DB].[dbo].[T_TMS_TaskComments] tc WITH (NOLOCK)
	LEFT JOIN [POMS_DB].[dbo].[T_Users] u WITH (NOLOCK) ON tc.AddedBy = u.USERNAME
	WHERE tc.IsActive = 1 AND tc.TD_ID = @TD_ID
	ORDER BY tc.AddedOn ASC
	
END;
GO
