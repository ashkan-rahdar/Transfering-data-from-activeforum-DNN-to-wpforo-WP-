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
    INSERT INTO [SimorghPortalZero972].[dbo].[wp_wpforo_topics] (
        topicid, forumid, first_postid, userid, title, slug, created, modified, 
        last_post, posts, votes, answers, views, meta_key, meta_desc, 
        type, solved, closed, has_attach, private, status, name, email, prefix, tags
    )
    VALUES (
        @NewTopicId,                    -- New Topic ID
        (SELECT new_forumid FROM [SimorghPortalZero972].[dbo].[wp_wpforo_meta_forums] WHERE original_forumid = @ForumId), -- New Forum ID
        1,                           -- first_postid (can be set later)
        @UserId,                       -- User ID from activeforums_Content
        @Title,                        -- Title from activeforums_Content
        CAST(@ForumId AS NVARCHAR) + '/' + CAST(@NewTopicId AS NVARCHAR), -- slug
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
    INSERT INTO [SimorghPortalZero972].[dbo].[wp_wpforo_meta_topics] (
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
