-- Create the wp_wpforo_forums table if it doesn't already exist in the transfering database
IF OBJECT_ID('[transfering].[dbo].[wp_wpforo_forums]', 'U') IS NULL
BEGIN
	CREATE TABLE transfering.dbo.wp_wpforo_forums (
		forumid INT PRIMARY KEY,
		title NVARCHAR(255) NULL,
		slug NVARCHAR(255) NULL,
		description NText NULL,
		parentid INT NULL DEFAULT 0,
		icon NVARCHAR(255) NULL DEFAULT 'fas fa-comments',
		cover BigInt NULL DEFAULT '0',
		cover_height INT NULL DEFAULT 150,
		last_topicid INT NULL DEFAULT 0,
		last_postid INT NULL DEFAULT 0,
		last_userid NVARCHAR(255) NULL DEFAULT '1',
		last_post_date DATETIME NULL DEFAULT '2024-10-07 08:39:32',
		topics INT DEFAULT 0,
		posts INT DEFAULT 0,
		permissions NText NULL DEFAULT 'a:5:{i:1;s:4:"full";i:2;s:9:"moderator";i:3;s:8:"standard";i:4;s:9:"read_only";i:5;s:8:"standard";}',
		meta_key Text NULL,
		meta_desc Text NULL,
		status TINYINT DEFAULT 1,
		is_cat TINYINT DEFAULT 1,
		layout TINYINT NULL DEFAULT 4,
		[order] INT NULL DEFAULT 0,
		color NVARCHAR(7) NULL DEFAULT '#888888'
	)
END

-- Create the wp_wpforo_meta_forums table if it doesn't already exist in the transfering database
IF OBJECT_ID('[transfering].[dbo].[wp_wpforo_meta_forums]', 'U') IS NULL
BEGIN
    CREATE TABLE [transfering].[dbo].[wp_wpforo_meta_forums] (
        original_forumid INT PRIMARY KEY,  -- ForumId from activeforums_Forums
        new_forumid INT                     -- forumid from wp_wpforo_forums
    );
END

DECLARE @CurrentGroupId INT, @CurrentGroupName NVARCHAR(255), @CurrentForumId INT
DECLARE @ForumGroupId INT, @ForumName NVARCHAR(255), @ForumDesc NVARCHAR(MAX), @DateCreated DateTime, @TotalTopics INT, @TotalReplies INT, @LastTopicId INT, @LastReplyId INT
DECLARE @LastInsertedGroupId INT
DECLARE @NextForumId INT = 1  -- Start from 1 for the forum ID

-- Cursor to iterate over activeforums_Groups where ModuleId is not 473
DECLARE GroupCursor CURSOR FOR
SELECT ForumGroupId, GroupName 
FROM [SimorghPortalZero972].[dbo].[activeforums_Groups]
WHERE ModuleId <> 473;

OPEN GroupCursor;

FETCH NEXT FROM GroupCursor INTO @CurrentGroupId, @CurrentGroupName;

-- Loop through each group
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert a new row into wp_wpforo_forums for the group in transfering database
    INSERT INTO [transfering].[dbo].[wp_wpforo_forums] (
        forumid, title, slug, description, parentid, icon, cover, cover_height, 
        last_topicid, last_postid, last_userid, last_post_date, topics, posts, 
        permissions, meta_key, meta_desc, status, is_cat, layout, [order], color
    )
    VALUES (
        @NextForumId, 
        @CurrentGroupName, 
        CAST(@NextForumId AS NVARCHAR(255)), -- slug will be handled by trigger
        NULL, -- description is NULL for groups
        0, -- parentid for group is 0 (no parent)
        'fas fa-comments', -- Default icon
        '0', -- Default cover
        150, -- Default cover_height
        0, 0, 1, '2024-10-07 08:39:32', -- last topic, post, user, date
        0, 0, -- topics and posts are 0 initially
        'a:5:{i:1;s:4:"full";i:2;s:9:"moderator";i:3;s:8:"standard";i:4;s:9:"read_only";i:5;s:8:"standard";}', 
        NULL, NULL, 1, 1, '1', 0, '#888888'
    );

    -- Capture the forum ID of the inserted group
    SET @LastInsertedGroupId = @NextForumId;
    SET @NextForumId = @NextForumId + 1; -- Increment for the next insert

    -- Now handle forums that belong to this group
    DECLARE ForumCursor CURSOR FOR
    SELECT ForumId, ForumName, ForumDesc, DateCreated, TotalTopics, TotalReplies, LastTopicId, LastReplyId
    FROM [SimorghPortalZero972].[dbo].[activeforums_Forums]
    WHERE ForumGroupId = @CurrentGroupId;

    OPEN ForumCursor;

    FETCH NEXT FROM ForumCursor INTO @ForumGroupId, @ForumName, @ForumDesc, @DateCreated, @TotalTopics, @TotalReplies, @LastTopicId, @LastReplyId;

    -- Loop through each forum in the group
    WHILE @@FETCH_STATUS = 0
    BEGIN
		Declare @LastPostId INT
		-- Get Content Id related to LastReplyId
		SELECT @LastPostId = ContentId
		FROM [SimorghPortalZero972].[dbo].[activeforums_Replies]
		WHERE ReplyId = @LastReplyId;

        -- Insert a new row into wp_wpforo_forums for the forum in transfering database
        INSERT INTO [transfering].[dbo].[wp_wpforo_forums] (
            forumid, title, slug, description, parentid, icon, cover, cover_height, 
            last_topicid, last_postid, last_userid, last_post_date, topics, posts, 
            permissions, meta_key, meta_desc, status, is_cat, layout, [order], color
        )
        VALUES (
            @NextForumId, 
            @ForumName, 
            CAST(@NextForumId AS NVARCHAR(255)), -- slug will be handled by trigger
            @ForumDesc, -- Forum description from activeforums_Forums
            @LastInsertedGroupId, -- parentid will be the group id
            'fas fa-comments', -- Default icon
            '0', -- Default cover
            150, -- Default cover_height
            @LastTopicId, @LastPostId, 1, @DateCreated, -- last topic, post, user, date
            @TotalTopics, @TotalReplies, -- topics and posts are 0 initially
            'a:5:{i:1;s:4:"full";i:2;s:9:"moderator";i:3;s:8:"standard";i:4;s:9:"read_only";i:5;s:8:"standard";}', 
            NULL, NULL, 1, 0, '1', 0, '#888888'
        );

        -- Insert the mapping into the meta_wp_forums table in transfering database
        INSERT INTO [transfering].[dbo].[wp_wpforo_meta_forums] (
            original_forumid, new_forumid
        )
        VALUES (
            @ForumGroupId, -- The ForumId from activeforums_Forums
            @NextForumId  -- The new forumid from wp_wpforo_forums
        );

        SET @NextForumId = @NextForumId + 1; -- Increment for the next insert

        FETCH NEXT FROM ForumCursor INTO @ForumGroupId, @ForumName, @ForumDesc, @DateCreated, @TotalTopics, @TotalReplies , @LastTopicId, @LastReplyId;
    END

    CLOSE ForumCursor;
    DEALLOCATE ForumCursor;

    -- Move to the next group
    FETCH NEXT FROM GroupCursor INTO @CurrentGroupId, @CurrentGroupName;
END;

CLOSE GroupCursor;
DEALLOCATE GroupCursor;
