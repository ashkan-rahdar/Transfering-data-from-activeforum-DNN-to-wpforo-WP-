CREATE TRIGGER trg_SetSlug
ON [SimorghPortalZero972].[dbo].[wp_wpforo_topics]
AFTER INSERT
AS
BEGIN
    UPDATE [SimorghPortalZero972].[dbo].[wp_wpforo_topics]
    SET slug = CONCAT(CAST(forumid AS NVARCHAR(255)), '/', CAST(topicid AS NVARCHAR(255))) -- Generate slug as 'forumid/topicid'
    WHERE topicid IN (SELECT topicid FROM inserted);
END;
