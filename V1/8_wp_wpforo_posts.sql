-- Create the wp_wpforo_posts table
CREATE TABLE [SimorghPortalZero972].[dbo].[wp_wpforo_posts] (
    postid INT PRIMARY KEY,               -- Post ID, primary key
    parentid INT DEFAULT 0,               -- Parent post ID, default is 0
    forumid INT NOT NULL,                 -- Forum ID to which the post belongs
    topicid INT NOT NULL,                 -- Topic ID to which the post belongs
    userid INT NOT NULL,                  -- User who created the post
    title NVARCHAR(255) NOT NULL,         -- Title of the post
    body NVARCHAR(MAX) NOT NULL,          -- Body content of the post
    created DATETIME NOT NULL,            -- Post creation date
    modified DATETIME NULL,               -- Post modification date, will be set via trigger
    likes INT DEFAULT 0,                  -- Number of likes, default 0
    votes INT DEFAULT 0,                  -- Number of votes, default 0
    is_answer TINYINT DEFAULT 0,          -- Whether the post is marked as an answer, default 0
    is_first_post TINYINT DEFAULT 0,      -- Whether the post is the first in the topic, default 0
    status TINYINT DEFAULT 0,             -- Status of the post, default 0
    name NVARCHAR(255) NULL,              -- Name of the post author (optional)
    email NVARCHAR(255) NULL,             -- Email of the post author (optional)
    private TINYINT DEFAULT 0,            -- Whether the post is private, default 0
    root INT DEFAULT -1                   -- Root post ID, default is -1
);
