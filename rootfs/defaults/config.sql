CREATE TABLE if not exists settings(key VARCHAR(255), value TEXT, PRIMARY KEY('key'));
INSERT or REPLACE INTO settings VALUES('default_down_dir','/output');