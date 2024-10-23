CREATE TRIGGER trg_SetSlugAsForumID
ON transfering.dbo.wp_wpforo_forums
AFTER INSERT
AS
BEGIN
    UPDATE transfering.dbo.wp_wpforo_forums
    SET slug = CAST(forumid AS NVARCHAR(255))
    WHERE slug IS NULL AND forumid IN (SELECT forumid FROM inserted);
END;
