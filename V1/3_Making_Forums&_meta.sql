-- Create the meta_wp_forums table if it doesn't already exist
IF OBJECT_ID('[SimorghPortalZero972].[dbo].[wp__wpforo_meta_forums]', 'U') IS NULL
BEGIN
    CREATE TABLE [SimorghPortalZero972].[dbo].[wp_wpforo_meta_forums] (
        original_forumid INT PRIMARY KEY,  -- ForumId from activeforums_Forums
        new_forumid INT                     -- forumid from wp_wpforo_forums
    );
END

DECLARE @CurrentGroupId INT, @CurrentGroupName NVARCHAR(255), @CurrentForumId INT
DECLARE @ForumGroupId INT, @ForumName NVARCHAR(255), @ForumDesc NVARCHAR(MAX), @DateCreated DateTime
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
    -- Insert a new row into wp_wpforo_forums for the group
    INSERT INTO [SimorghPortalZero972].[dbo].[wp_wpforo_forums] (
        forumid, title, slug, description, parentid, icon, cover, cover_height, 
        last_topicid, last_postid, last_userid, last_post_date, topics, posts, 
        permissions, meta_key, meta_desc, status, is_cat, layout, [order], color
    )
    VALUES (
        @NextForumId, 
        @CurrentGroupName, 
        NULL, -- slug will be handled by trigger
        NULL, -- description is NULL for groups
        0, -- parentid for group is 0 (no parent)
        'fas fa-comments', -- Default icon
        '0', -- Default cover
        150, -- Default cover_height
        0, 0, 1, '2024-10-07 08:39:32', -- last topic, post, user, date
        0, 0, -- topics and posts are 0 initially
        'a:5:{i:1;s:4:"full";i:2;s:9:"moderator";i:3;s:8:"standard";i:4;s:9:"read_only";i:5;s:8:"standard";}', 
        NULL, NULL, 1, 1, '4', 0, '#888888'
    );

    -- Capture the forum ID of the inserted group
    SET @LastInsertedGroupId = @NextForumId;
    SET @NextForumId = @NextForumId + 1; -- Increment for the next insert

    -- Now handle forums that belong to this group
    DECLARE ForumCursor CURSOR FOR
    SELECT ForumId, ForumName, ForumDesc, DateCreated
    FROM [SimorghPortalZero972].[dbo].[activeforums_Forums]
    WHERE ForumGroupId = @CurrentGroupId;

    OPEN ForumCursor;

    FETCH NEXT FROM ForumCursor INTO @ForumGroupId, @ForumName, @ForumDesc, @DateCreated;

    -- Loop through each forum in the group
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Insert a new row into wp_wpforo_forums for the forum
        INSERT INTO [SimorghPortalZero972].[dbo].[wp_wpforo_forums] (
            forumid, title, slug, description, parentid, icon, cover, cover_height, 
            last_topicid, last_postid, last_userid, last_post_date, topics, posts, 
            permissions, meta_key, meta_desc, status, is_cat, layout, [order], color
        )
        VALUES (
            @NextForumId, 
            @ForumName, 
            NULL, -- slug will be handled by trigger
            @ForumDesc, -- Forum description from activeforums_Forums
            @LastInsertedGroupId, -- parentid will be the group id
            'fas fa-comments', -- Default icon
            '0', -- Default cover
            150, -- Default cover_height
            0, 0, 1, @DateCreated, -- last topic, post, user, date
            0, 0, -- topics and posts are 0 initially
            'a:5:{i:1;s:4:"full";i:2;s:9:"moderator";i:3;s:8:"standard";i:4;s:9:"read_only";i:5;s:8:"standard";}', 
            NULL, NULL, 1, 0, '4', 0, '#888888'
        );

        -- Insert the mapping into the meta_wp_forums table
        INSERT INTO [SimorghPortalZero972].[dbo].[wp_wpforo_meta_forums] (
            original_forumid, new_forumid
        )
        VALUES (
            @ForumGroupId, -- The ForumId from activeforums_Forums
            @NextForumId  -- The new forumid from wp_wpforo_forums
        );

        SET @NextForumId = @NextForumId + 1; -- Increment for the next insert

        FETCH NEXT FROM ForumCursor INTO @ForumGroupId, @ForumName, @ForumDesc, @DateCreated;
    END

    CLOSE ForumCursor;
    DEALLOCATE ForumCursor;

    -- Move to the next group
    FETCH NEXT FROM GroupCursor INTO @CurrentGroupId, @CurrentGroupName;
END;

CLOSE GroupCursor;
DEALLOCATE GroupCursor;
