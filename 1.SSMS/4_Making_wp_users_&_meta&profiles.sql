-- Create wp_users table if not exists
IF OBJECT_ID('[transfering].[dbo].[wp_users]', 'U') IS NULL
BEGIN
    CREATE TABLE [transfering].[dbo].[wp_users] (
        ID BIGINT PRIMARY KEY IDENTITY(2,1),  -- Start the ID at 2 and auto-increment by 1
        user_login NVARCHAR(60) NOT NULL,
        user_pass NVARCHAR(255) NOT NULL,
        user_nicename NVARCHAR(50) NOT NULL,
        user_email NVARCHAR(100) NOT NULL,
        user_url NVARCHAR(100),
        user_registered DATETIME NOT NULL DEFAULT ('2024-10-02 14:10:40'),
        user_activation_key NVARCHAR(255),
        user_status INT NOT NULL DEFAULT 0,
        display_name NVARCHAR(250) NOT NULL
    );
END

-- Create user_mappings table to track relationship between old and new user IDs
IF OBJECT_ID('[transfering].[dbo].[wp_meta_users]', 'U') IS NULL
BEGIN
    CREATE TABLE [transfering].[dbo].[wp_meta_users] (
        old_UserID INT PRIMARY KEY,  -- UserID from the old system
        new_ID INT  -- Corresponding new ID in wp_users
    );
END

-- Create wp_wpforo_profiles table if not exists
IF OBJECT_ID('[transfering].[dbo].[wp_wpforo_profiles]', 'U') IS NULL
BEGIN
    CREATE TABLE [transfering].[dbo].[wp_wpforo_profiles] (
        userid BIGINT NULL,
        title NVARCHAR(255) DEFAULT 'Member',
        groupid INT DEFAULT 3,  -- Setting groupid to 3 as requested
        secondary_groupids NVARCHAR(255) DEFAULT NULL,
        avatar NVARCHAR(991) DEFAULT NULL,
        cover NVARCHAR(255) DEFAULT NULL,
        posts INT DEFAULT 0,
        topics INT DEFAULT 0,
        questions INT DEFAULT 0,
        answers INT DEFAULT 0,
        comments INT DEFAULT 0,
        reactions_in TEXT NULL,
        reactions_out TEXT NULL,
        points INT DEFAULT 0,
        custom_points INT DEFAULT 0,
        online_time INT DEFAULT 0,
        timezone NVARCHAR(255) NULL,
        location NVARCHAR(255) NULL,
        signature TEXT NULL,
        about TEXT NULL,
        occupation TEXT NULL,
        status NVARCHAR(8) DEFAULT 'active',
        is_email_confirmed INT DEFAULT 0,
        is_mention_muted INT DEFAULT 0,
        fields TEXT DEFAULT NULL
    );
END

-- Declare variables to use for inserting data
DECLARE @OldUserID INT, @Username NVARCHAR(60), @DisplayName NVARCHAR(50), @Email NVARCHAR(100), @NewID INT;
DECLARE @posts INT, @topics INT;

-- Start processing users from the old Users table
DECLARE UserCursor CURSOR FOR
SELECT UserID, Username, DisplayName, Email
FROM [SimorghPortalZero972].[dbo].[Users];

OPEN UserCursor;

FETCH NEXT FROM UserCursor INTO @OldUserID, @Username, @DisplayName, @Email;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert into wp_users
    INSERT INTO [transfering].[dbo].[wp_users] (
        user_login, user_pass, user_nicename, user_email, user_url, user_registered, user_activation_key, user_status, display_name
    )
    VALUES (
        @Username,
        '$P$BNryRLMcLaqx6C/P1EeUeSeHGxH7Lu/',  -- Replace this with the correct WordPress hashed password
        REPLACE(@DisplayName, ' ', '-'),
        @Email,
        NULL,
        '2024-10-02 14:10:40',
        NULL,
        0,
        @DisplayName
    );

    -- Get the new ID just inserted
    SET @NewID = SCOPE_IDENTITY();

    -- Insert the mapping into the user_mappings table
    INSERT INTO [transfering].[dbo].[wp_meta_users] (old_UserID, new_ID)
    VALUES (@OldUserID, @NewID);

    -- Get the ReplyCount and TopicCount from activeforums_UserProfiles if available
    SELECT  @posts = ReplyCount, @topics = TopicCount
    FROM [SimorghPortalZero972].[dbo].[activeforums_UserProfiles]
    WHERE UserId = @OldUserID;

    -- Insert into wp_wpforo_profiles using the new ID and retrieved counts
    INSERT INTO [transfering].[dbo].[wp_wpforo_profiles] (
        userid, title, groupid, secondary_groupids, avatar, cover, posts, topics, questions, answers, comments, reactions_in, reactions_out, points, custom_points, online_time, timezone, location, signature, about, occupation, status, is_email_confirmed, is_mention_muted, fields
    )
    VALUES (
        @NewID,            -- userid matches new ID from wp_users
        'Member',          -- title
        3,                 -- groupid
        NULL, NULL, NULL,  -- secondary_groupids, avatar, cover
        ISNULL(@posts, 0) + ISNULL(@topics, 0),    -- posts
        ISNULL(@topics, 0),    -- topics
        0, 0, 0,           -- questions, answers, comments
        NULL, NULL,        -- reactions_in, reactions_out
        0, 0, 0,           -- points, custom_points, online_time
        NULL, NULL, NULL, NULL, NULL,  -- timezone, location, signature, about, occupation
        'active',          -- status
        0, 0, NULL         -- is_email_confirmed, is_mention_muted, fields
    );

    -- Reset variables for the next iteration
    SET @posts = NULL;
    SET @topics = NULL;

    -- Fetch next user
    FETCH NEXT FROM UserCursor INTO @OldUserID, @Username, @DisplayName, @Email;
END;

CLOSE UserCursor;
DEALLOCATE UserCursor;
