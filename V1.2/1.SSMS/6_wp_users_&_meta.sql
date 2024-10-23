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
		userid INT NULL,
		title NVARCHAR(255) DEFAULT 'Member',
		groupid INT DEFAULT 3,  -- Setting groupid to 3 as requested
		secondary_groupid INT NULL,
		avatars NVARCHAR(MAX) NULL,
		cover NVARCHAR(MAX) NULL,
		posts INT DEFAULT 0,
		topics INT DEFAULT 0,
		questions INT DEFAULT 0,
		answers INT DEFAULT 0,
		comments INT DEFAULT 0,
		reactions_in INT NULL,
		reactions_out INT NULL,
		points INT DEFAULT 0,
		custom_points INT DEFAULT 0,
		online_time INT DEFAULT 0,
		timezone NVARCHAR(255) NULL,
		location NVARCHAR(255) NULL,
		signature NVARCHAR(MAX) NULL,
		about NVARCHAR(MAX) NULL,
		occupation NVARCHAR(MAX) NULL,
		status NVARCHAR(50) DEFAULT 'active',
		is_email_confirmed INT DEFAULT 0,
		is_mention_muted INT DEFAULT 0,
		fields NVARCHAR(MAX) NULL
	);
END

-- Declare variables to use for inserting data
DECLARE @OldUserID INT, @Username NVARCHAR(60), @DisplayName NVARCHAR(50), @Email NVARCHAR(100), @NewID INT;

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
        '$P$BNryRLMcLaqx6C/P1EeUeSeHGxH7Lu/',  -- You need to replace this with the correct WordPress hashed password
        @DisplayName,
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

    -- Insert into wp_wpforo_profiles using the same new ID
    INSERT INTO [transfering].[dbo].[wp_wpforo_profiles] (
        userid, title, groupid, secondary_groupid, avatars, cover, posts, topics, questions, answers, comments, reactions_in, reactions_out, points, custom_points, online_time, timezone, location, signature, about, occupation, status, is_email_confirmed, is_mention_muted, fields
    )
    VALUES (
        @NewID,  -- userid matches new ID from wp_users
        'Member',  -- title
        3,  -- groupid
        NULL, NULL, NULL,  -- secondary_groupid, avatars, cover
        0, 0, 0, 0, 0,  -- posts, topics, questions, answers, comments
        NULL, NULL,  -- reactions_in, reactions_out
        0, 0, 0,  -- points, custom_points, online_time
        NULL, NULL, NULL, NULL, NULL,  -- timezone, location, signature, about, occupation
        'active',  -- status
        0, 0, NULL  -- is_email_confirmed, is_mention_muted, fields
    );

    -- Fetch next user
    FETCH NEXT FROM UserCursor INTO @OldUserID, @Username, @DisplayName, @Email;
END;

CLOSE UserCursor;
DEALLOCATE UserCursor;
