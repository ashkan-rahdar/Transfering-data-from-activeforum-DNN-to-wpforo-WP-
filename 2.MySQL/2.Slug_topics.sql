DELIMITER //

-- BEFORE INSERT trigger to set slug to match topicid
CREATE TRIGGER trg_wp_wpforo_topics_before_insert
BEFORE INSERT ON test2.wp_wpforo_topics
FOR EACH ROW
BEGIN
    SET NEW.slug = NEW.topicid;
END //

-- BEFORE UPDATE trigger to set slug to match topicid
CREATE TRIGGER trg_wp_wpforo_topics_before_update
BEFORE UPDATE ON test2.wp_wpforo_topics
FOR EACH ROW
BEGIN
    SET NEW.slug = NEW.topicid;
END //

DELIMITER ;