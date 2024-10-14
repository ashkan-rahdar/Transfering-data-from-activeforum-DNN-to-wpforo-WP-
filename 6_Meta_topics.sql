-- Create the wp_wpforo_meta_topics table if it doesn't already exist
IF OBJECT_ID('[SimorghPortalZero972].[dbo].[wp_wpforo_meta_topics]', 'U') IS NULL
BEGIN
    CREATE TABLE [SimorghPortalZero972].[dbo].[wp_wpforo_meta_topics] (
        original_topicid INT PRIMARY KEY,   -- TopicId from activeforums_Topics
        new_topicid INT                     -- TopicId from wp_wpforo_topics
    );
END
