CREATE TABLE if not exists settings(key VARCHAR(255), value TEXT, PRIMARY KEY('key'));
INSERT or REPLACE INTO settings VALUES('smart_proxy','yes');
INSERT or REPLACE INTO settings VALUES('default_down_dir','/output');
INSERT or REPLACE INTO settings VALUES ('custom_proxy_list','#https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt');