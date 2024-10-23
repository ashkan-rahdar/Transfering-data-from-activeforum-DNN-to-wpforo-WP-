USE transfering;

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
);


