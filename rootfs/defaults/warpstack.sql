CREATE TABLE if not exists settings(key VARCHAR(255), value TEXT, PRIMARY KEY('key'));
INSERT or REPLACE INTO settings VALUES('run_command','yes');
INSERT or REPLACE INTO settings VALUES('run_command_path','/config/reset.sh');