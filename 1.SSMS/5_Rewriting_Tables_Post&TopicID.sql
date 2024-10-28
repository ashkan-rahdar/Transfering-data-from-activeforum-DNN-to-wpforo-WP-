-- Update last_topicid in wp_wpforo_forums based on wp_wpforo_meta_topics
UPDATE f
SET f.last_topicid = mt.new_topicid
FROM [transfering].[dbo].[wp_wpforo_forums] f
JOIN [transfering].[dbo].[wp_wpforo_meta_topics] mt
    ON f.last_topicid = mt.original_topicid;

-- Update last_postid in wp_wpforo_forums based on wp_wpforo_meta_posts
UPDATE f
SET f.last_postid = mp.new_postid
FROM [transfering].[dbo].[wp_wpforo_forums] f
JOIN [transfering].[dbo].[wp_wpforo_meta_posts] mp
    ON f.last_postid = mp.original_contentid;

UPDATE topics
SET topics.last_post = meta_posts.new_postid
FROM [transfering].[dbo].[wp_wpforo_topics] AS topics
INNER JOIN [transfering].[dbo].[wp_wpforo_meta_topics] AS meta_topics
    ON topics.topicid = meta_topics.new_topicid
INNER JOIN [SimorghPortalZero972].[dbo].[activeforums_Topics_Tracking] AS topics_tracking
    ON meta_topics.original_topicid = topics_tracking.TopicId
INNER JOIN [SimorghPortalZero972].[dbo].[activeforums_Replies] AS replies
    ON topics_tracking.LastReplyId = replies.ReplyId
INNER JOIN [transfering].[dbo].[wp_wpforo_meta_posts] AS meta_posts
    ON replies.ContentId = meta_posts.original_contentid;
