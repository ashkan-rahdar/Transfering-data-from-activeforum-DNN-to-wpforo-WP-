-- Create the wp_wpforo_topics table in the transfering database
CREATE TABLE [transfering].[dbo].[wp_wpforo_topics] (
    topicid BIGINT PRIMARY KEY,              -- Topic ID, primary key
    forumid INT NOT NULL,                 -- ID of the forum to which the topic belongs
    first_postid BIGINT NOT NULL DEFAULT 1,  -- ID of the first post in the topic
    userid INT NOT NULL,                  -- User who created the topic
    title NVARCHAR(255) NOT NULL,         -- Title of the topic
    slug NVARCHAR(255) NULL,              -- Slug will be generated in the trigger
    created DATETIME NOT NULL,            -- Topic creation date
    modified DATETIME NULL,               -- Topic modification date (will be set via trigger)
    last_post BIGINT NULL,                   -- ID of the last post in the topic
    posts INT DEFAULT 0,                  -- Total number of posts in the topic, default 0
    votes INT DEFAULT 0,                  -- Number of votes, default 0
    answers INT DEFAULT 0,                -- Number of answers, default 0
    views INT DEFAULT 0,                  -- Number of views, default 0
    meta_key TEXT NULL,          -- SEO meta key, optional
    meta_desc TEXT NULL,         -- SEO meta description, optional
    type TINYINT DEFAULT 0,               -- Type of topic, default 0
    solved TINYINT DEFAULT 0,             -- Whether the topic is marked as solved, default 0
    closed TINYINT DEFAULT 0,             -- Whether the topic is closed, default 0
    has_attach TINYINT DEFAULT 0,         -- Whether the topic has attachments, default 0
    private TINYINT DEFAULT 0,            -- Whether the topic is private, default 0
    status TINYINT DEFAULT 0,             -- Status of the topic, default 0
    name NVARCHAR(50) NULL,              -- Name of the topic starter (optional)
    email NVARCHAR(50) NULL,             -- Email of the topic starter (optional)
    prefix NVARCHAR(100) NULL,             -- Prefix for the topic (optional)
    tags TEXT NULL               -- Tags associated with the topic (optional)
);

-- Create the wp_wpforo_meta_topics table if it doesn't already exist
IF OBJECT_ID('[transfering].[dbo].[wp_wpforo_meta_topics]', 'U') IS NULL
BEGIN
    CREATE TABLE [transfering].[dbo].[wp_wpforo_meta_topics] (
        original_topicid INT PRIMARY KEY,   -- TopicId from activeforums_Topics
        new_topicid INT                     -- TopicId from wp_wpforo_topics
    );
END

DECLARE @ForumId INT, @TopicId INT, @LastReplyId INT, @LastPostDate DATETIME, 
        @UserId INT, @Title NVARCHAR(255), @Created DATETIME, @Modified DATETIME, 
        @NewTopicId INT = 1;  -- Start from 1 for the new Topic ID

-- Cursor to iterate over approved topics in activeforums_Topics
DECLARE TopicCursor CURSOR FOR
SELECT T.TopicId, FT.ForumId, FT.LastReplyId, FT.LastPostDate
FROM [SimorghPortalZero972].[dbo].[activeforums_Topics] T
JOIN [SimorghPortalZero972].[dbo].[activeforums_ForumTopics] FT ON T.TopicId = FT.TopicId
WHERE T.IsApproved = 1 AND T.IsRejected = 0 AND T.IsDeleted = 0 AND T.IsAnnounce = 0;

OPEN TopicCursor;

FETCH NEXT FROM TopicCursor INTO @TopicId, @ForumId, @LastReplyId, @LastPostDate;

-- Loop through each approved topic
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Retrieve the ContentId from the activeforums_Topics table for the current TopicId
    DECLARE @ContentId INT;
    SELECT @ContentId = ContentId FROM [SimorghPortalZero972].[dbo].[activeforums_Topics] WHERE TopicId = @TopicId;

    -- Get user information and other details from activeforums_Content
    SELECT @UserId = AuthorId, @Title = Subject, @Created = DateCreated, @Modified = DateUpdated
    FROM [SimorghPortalZero972].[dbo].[activeforums_Content]
    WHERE ContentId = @ContentId;

    -- Insert a new row into wp_wpforo_topics
    INSERT INTO [transfering].[dbo].[wp_wpforo_topics] (
        topicid, forumid, first_postid, userid, title, slug, created, modified, 
        last_post, posts, votes, answers, views, meta_key, meta_desc, 
        type, solved, closed, has_attach, private, status, name, email, prefix, tags
    )
    VALUES (
        @NewTopicId,                    -- New Topic ID
        (SELECT new_forumid FROM [transfering].[dbo].[wp_wpforo_meta_forums] WHERE original_forumid = @ForumId), -- New Forum ID
        1,                           -- first_postid (can be set later)
        @UserId,                       -- User ID from activeforums_Content
        @Title,                        -- Title from activeforums_Content
        CAST(@NewTopicId AS NVARCHAR), -- slug
        @Created,                      -- Created date from activeforums_Content
        @Modified,                     -- Modified date from activeforums_Content
        NULL,                           -- last_post (can be set later)
        0,                              -- posts default to 0
        0,                              -- votes default to 0
        0,                              -- answers default to 0
        0,                              -- views default to 0
        NULL,                           -- meta_key
        NULL,                           -- meta_desc
        0,                              -- type default to 0
        0,                              -- solved default to 0
        0,                              -- closed default to 0
        0,                              -- has_attach default to 0
        0,                              -- private default to 0
        0,                              -- status default to 0
        NULL,                           -- name default to NULL
        NULL,                           -- email default to NULL
        NULL,                           -- prefix default to NULL
        NULL                            -- tags default to NULL
    );

    -- Insert the mapping into the wp_wpforo_meta_topics table
    INSERT INTO [transfering].[dbo].[wp_wpforo_meta_topics] (
        original_topicid, new_topicid
    )
    VALUES (
        @TopicId,  -- The original TopicId from activeforums_Topics
        @NewTopicId  -- The new TopicId from wp_wpforo_topics
    );

    -- Increment for the next insert
    SET @NewTopicId = @NewTopicId + 1;

    FETCH NEXT FROM TopicCursor INTO @TopicId, @ForumId, @LastReplyId, @LastPostDate;
END

CLOSE TopicCursor;
DEALLOCATE TopicCursor;
