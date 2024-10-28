DELETE FROM test2.wp_wpforo_forums WHERE status=1;
DELETE FROM test2.wp_wpforo_topics WHERE type=0;
DELETE FROM test2.wp_wpforo_profiles WHERE userid!=1;
DELETE FROM test2.wp_users WHERE ID!=1;
DELETE FROM test2.wp_wpforo_posts WHERE root=-1;

INSERT IGNORE INTO test2.wp_wpforo_forums select *from transfering.wp_wpforo_forums;
INSERT IGNORE INTO test2.wp_users select *from transfering.wp_users;
INSERT IGNORE INTO test2.wp_wpforo_posts select *from transfering.wp_wpforo_posts;
INSERT IGNORE INTO test2.wp_wpforo_profiles select *from transfering.wp_wpforo_profiles;
INSERT IGNORE INTO test2.wp_wpforo_topics select *from transfering.wp_wpforo_topics;