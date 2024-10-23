-- Create wp_wpforo_posts table if it doesn't already exist
IF OBJECT_ID('[transfering].[dbo].[wp_wpforo_posts]', 'U') IS NULL
BEGIN
    CREATE TABLE [transfering].[dbo].[wp_wpforo_posts] (
        postid BIGINT PRIMARY KEY,            -- New post ID
        parentid BIGINT DEFAULT 0,            -- Default parentid is 0
        forumid INT,                       -- New forum ID
        topicid BIGINT,                       -- Related topic ID
        userid INT,                        -- User ID
        title NVARCHAR(255),               -- Post title
        body NTEXT,                -- Post body (with Summary added)
        created DATETIME,                  -- Creation time
        modified DATETIME,                 -- Last modification time (same as created initially)
        likes INT DEFAULT 0,               -- Default 0 for likes
        votes INT DEFAULT 0,               -- Default 0 for votes
        is_answer tinyint DEFAULT 0,           -- Default 0 for is_answer
        is_first_post tinyint DEFAULT 0,       -- Default 0 for is_first_post
        status tinyint DEFAULT 0,              -- Default 0 for status
        name NVARCHAR(50) NULL,           -- Can be NULL
        email NVARCHAR(50) NULL,          -- Can be NULL
        private tinyint DEFAULT 0,             -- Default 0 for private
        root BIGINT DEFAULT -1                -- Default -1 for root
    );
END;

-- Create wp_wpforo_meta_posts table if it doesn't already exist
IF OBJECT_ID('[transfering].[dbo].[wp_wpforo_meta_posts]', 'U') IS NULL
BEGIN
    CREATE TABLE [transfering].[dbo].[wp_wpforo_meta_posts] (
        original_contentid INT PRIMARY KEY,  -- ContentId from activeforums_Content
        new_postid INT                       -- New postid in wp_wpforo_posts
    );
END;

-- Declare variables
DECLARE @CurrentContentId INT, @TopicId INT, @NewTopicId INT, @ForumId INT, @NewForumId INT;
DECLARE @UserId INT, @Title NVARCHAR(255),@Summary NVARCHAR(MAX), @Body NVARCHAR(MAX), @Created DATETIME, @Modified DATETIME;
DECLARE @NextPostId INT = 1;  -- Start with the first post ID

-- Cursor to iterate over activeforums_Content where IsDeleted = 0
DECLARE ContentCursor CURSOR FOR
SELECT ContentId, AuthorId, Subject, Summary, Body, DateCreated, DateUpdated
FROM [SimorghPortalZero972].[dbo].[activeforums_Content]
WHERE IsDeleted = 0;

OPEN ContentCursor;

FETCH NEXT FROM ContentCursor INTO @CurrentContentId, @UserId, @Title, @Summary, @Body, @Created, @Modified;

-- Loop through each row in activeforums_Content
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Find the TopicId related to the current ContentId from activeforums_Topics
    SELECT @TopicId = TopicId
    FROM [SimorghPortalZero972].[dbo].[activeforums_Topics]
    WHERE ContentId = @CurrentContentId;

	SELECT @TopicId = TopicId
    FROM [SimorghPortalZero972].[dbo].[activeforums_Replies]
    WHERE ContentId = @CurrentContentId;

    -- Find the new Topic ID using wp_wpforo_meta_topics
    SELECT @NewTopicId = new_topicid
    FROM [transfering].[dbo].[wp_wpforo_meta_topics]
    WHERE original_topicid = @TopicId;

    -- Find the ForumId related to the TopicId from activeforums_ForumTopics
    SELECT @ForumId = ForumId
    FROM [SimorghPortalZero972].[dbo].[activeforums_ForumTopics]
    WHERE TopicId = @TopicId;

    -- Find the new forum ID using wp_wpforo_meta_forums
    SELECT @NewForumId = new_forumid
    FROM [transfering].[dbo].[wp_wpforo_meta_forums]
    WHERE original_forumid = @ForumId;

    -- Insert a new row into wp_wpforo_posts
    INSERT INTO [transfering].[dbo].[wp_wpforo_posts] (
        postid, parentid, forumid, topicid, userid, title, body, created, modified, 
        likes, votes, is_answer, is_first_post, status, name, email, private, root
    )
    VALUES (
        @NextPostId, 
        0, -- parentid is 0 for the initial posts
        @NewForumId, 
        @NewTopicId, 
        @UserId, 
        @Title, 
        '<p>' + ISNULL(@Summary, '') + '</p> ' + @Body, -- Combining the summary and body
        @Created, 
        @Modified, 
        0, 0, 0, 0, 0, -- Default values
        NULL, NULL, 0, -1
    );

    -- Insert the mapping of ContentId to the new postid into wp_wpforo_meta_posts
    INSERT INTO [transfering].[dbo].[wp_wpforo_meta_posts] (
        original_contentid, new_postid
    )
    VALUES (
        @CurrentContentId, 
        @NextPostId
    );

    -- Increment post ID for the next row
    SET @NextPostId = @NextPostId + 1;

    -- Move to the next content row
    FETCH NEXT FROM ContentCursor INTO @CurrentContentId, @UserId, @Title, @Summary, @Body, @Created, @Modified;
END;

CLOSE ContentCursor;
DEALLOCATE ContentCursor;
