USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddLinkedTask]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Exec P_AddLinkedTask 102, '101,100,98,99','IHTISHAM.ULHAQ'	 				 
CREATE PROC [dbo].[P_AddLinkedTask]
    @ParentTaskID INT,
    @LinkTaskIDS NVARCHAR(MAX),
    @Username NVARCHAR(150),
    @IPAddress NVARCHAR(20) = ''
AS
BEGIN
     
    DECLARE @Return_Code BIT = 1;
    DECLARE @Return_Text NVARCHAR(1000) = '';
    DECLARE @maxLinkID INT = 0;
    DECLARE @CountLinkID INT = 0;
    DECLARE @LinkTaskID INT = 0;
    
    DECLARE @LinkTaskIDTable TABLE (ID INT IDENTITY(1,1), LinkTaskID INT);
   INSERT INTO @LinkTaskIDTable (LinkTaskID) SELECT CONVERT(INT, value) FROM STRING_SPLIT(@LinkTaskIDS, ',');

    SET @maxLinkID = (SELECT COUNT(*) FROM @LinkTaskIDTable);
    
    WHILE @CountLinkID < @maxLinkID 
    BEGIN
        SET @CountLinkID = @CountLinkID + 1;
        SELECT @LinkTaskID = LinkTaskID FROM @LinkTaskIDTable WHERE ID = @CountLinkID;
        
        IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_LinkedTasks] WITH (NOLOCK) WHERE (Parent_TD = @ParentTaskID OR Parent_TD = @LinkTaskID) AND (LinkedTask_TD = @ParentTaskID OR LinkedTask_TD = @LinkTaskID) AND IsActive = 0)
        BEGIN
		    update [POMS_DB].[dbo].[T_TMS_LinkedTasks] set IsActive=1 ,ModifiedBy=@Username,ModifiedOn =GETUTCDATE() WHERE Parent_TD = @ParentTaskID AND LinkedTask_TD = @LinkTaskID
            SET @Return_Text = @Return_Text +'Task Re Linked: Parent ID ' + CAST(@ParentTaskID AS NVARCHAR(10)) + ', Linked Task ID: ' + CAST(@LinkTaskID AS NVARCHAR(10));
			set @Return_Code=1
        END
		Else IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_LinkedTasks] WITH (NOLOCK) WHERE(Parent_TD = @ParentTaskID OR Parent_TD = @LinkTaskID) AND (LinkedTask_TD = @ParentTaskID OR LinkedTask_TD = @LinkTaskID)  AND IsActive=1)
        BEGIN
            SET @Return_Text = @Return_Text +'Task Already Linked: Parent ID ' + CAST(@ParentTaskID AS NVARCHAR(10)) + ', Linked Task ID: ' + CAST(@LinkTaskID AS NVARCHAR(10));
			set @Return_Code=1
        END
        ELSE
        BEGIN

            INSERT INTO [dbo].[T_TMS_LinkedTasks] (Parent_TD, LinkedTask_TD, IsActive, AddedBy, AddedOn)
            VALUES (@ParentTaskID, @LinkTaskID, 1, @Username, GETUTCDATE());
			set @Return_Code=1
            SET @Return_Text = @Return_Text + 'Task Linked Successfully ';
        END;
    END;

    SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code;
END;


 
GO
