-- Create the wp_wpforo_topics table
CREATE TABLE [SimorghPortalZero972].[dbo].[wp_wpforo_topics] (
    topicid INT PRIMARY KEY,              -- Topic ID, primary key
    forumid INT NOT NULL,                 -- ID of the forum to which the topic belongs
    first_postid INT NOT NULL DEFAULT 1,            -- ID of the first post in the topic
    userid INT NOT NULL,                  -- User who created the topic
    title NVARCHAR(255) NOT NULL,         -- Title of the topic
    slug NVARCHAR(255) NULL,              -- Slug will be generated in the trigger
    created DATETIME NOT NULL,            -- Topic creation date
    modified DATETIME NULL,               -- Topic modification date (will be set via trigger)
    last_post INT NULL,                   -- ID of the last post in the topic
    posts INT DEFAULT 0,                  -- Total number of posts in the topic, default 0
    votes INT DEFAULT 0,                  -- Number of votes, default 0
    answers INT DEFAULT 0,                -- Number of answers, default 0
    views INT DEFAULT 0,                  -- Number of views, default 0
    meta_key NVARCHAR(255) NULL,          -- SEO meta key, optional
    meta_desc NVARCHAR(500) NULL,         -- SEO meta description, optional
    type TINYINT DEFAULT 0,               -- Type of topic, default 0
    solved TINYINT DEFAULT 0,             -- Whether the topic is marked as solved, default 0
    closed TINYINT DEFAULT 0,             -- Whether the topic is closed, default 0
    has_attach TINYINT DEFAULT 0,         -- Whether the topic has attachments, default 0
    private TINYINT DEFAULT 0,            -- Whether the topic is private, default 0
    status TINYINT DEFAULT 0,             -- Status of the topic, default 0
    name NVARCHAR(255) NULL,              -- Name of the topic starter (optional)
    email NVARCHAR(255) NULL,             -- Email of the topic starter (optional)
    prefix NVARCHAR(50) NULL,             -- Prefix for the topic (optional)
    tags NVARCHAR(255) NULL               -- Tags associated with the topic (optional)
);
