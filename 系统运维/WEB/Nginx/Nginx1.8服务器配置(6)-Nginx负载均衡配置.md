# nginx upstream
* upstream
```
����http���С�
�﷨��ʽ��upstream <name> { ... }
���ã�����������顣name�������ָ����

ʾ��:
upstream backend {
    server backend1.example.com weight=5;
    server 127.0.0.1:8080       max_fails=3 fail_timeout=30s;
    server unix:/tmp/backend3;

    server backup1.example.com  backup;
}
```

* server
```
����upstream���С�

�﷨��ʽ��server address [parameters];
���ã�ָ���������ĵ�ַ�Ͳ�����
˵����address������IP��ַ��Ҳ�������������Լ�һ����ѡ�Ķ˿ںš��磺server 172.17.100.1:8080�����û��ָ���˿ڣ���Ĭ��Ϊ80�˿ڡ�������������������IP��ַ�����ʾһ�ζ����˶��server��

�������£�
weight=<number>�����÷�������Ȩ�ء�Ĭ��Ϊ1.
max_conns=<number>�����ƺ�˷�����ͬʱ��������������Ĭ��ֵΪ0����ʾû�����ơ������������û��ʹ�ù����ڴ�(zone)�Ļ��������������ʾ����ÿ��worker���̵����ơ�
max_fails=<number>��Ĭ��ֵΪ1.��ʾ�������ĳ̨��������fail_timeout��ָ����ʱ���ڳ���max_fails�η���ʧ�ܣ�����fail_timeoutʱ������Ϊ�÷����������á����Ϊ0�����ʾ�رոù��ܡ�����ͨ��ָ��proxy_next_upstream�� fastcgi_next_upstream�� memcached_next_upstream������ʲô��ʧ�ܵĳ��ԡ� Ĭ������ʱ��http_404״̬������Ϊ��ʧ�ܵĳ��ԡ�
fail_timeout=<time>��Ĭ��Ϊ10s����ʾ�������ڸ�ʱ�����ʧ��max_fails�κ󣬷������������õ�ʱ�䡣
backup����Ƿ�������Ϊ���ݷ������������е���������������ʱ���Ż�ʹ�ñ��Ϊbackup�ķ�������
down����Ƿ��������ò����á�
resolve�����ӷ���������������Ӧ��IP��ַ�ĸı䣬���������������ı�ʱ�������Զ����޸�upstream�����ã�����Ҫ����nginx����Ҫ��http��������resolverָ��������DNS��������
```

* zone
```
����upstream���С�1.9.0�汾���á�
�﷨��ʽ��zone <name> [size]
���ã����������ڶ��worker����֮�乲�����������Ϣ������״̬��Ϣ�Ĺ����ڴ�����ƺʹ�С����������Թ���ͬһ��zone������������£� ��Ҫһ����ָ���㹻��size��
```

* keepalive
```
����upstream���С����ڴ������������˷������ĳ����ӡ�http���е�keepalive��ʾ���ǿͻ��˵�web������֮��ĳ����ӡ�
�﷨��keepalive <connections>
���ã�Ϊ�Ӵ������������˷����������Ӽ���档connections������ʾΪÿһ��worker���̱����ڻ����е������еĵ���˷������������������������ֵ�����������ʹ�õ����ӽ��ᱻ�رա�

ע�⣺
1. ����HTTP��������Ӧ������proxy_http_versionΪ1.1�����ҽ�Connectionͷ�ֶ���ա�
2. ����FastCGI����������Ҫ����fastcgi_keep_connΪon��

����ʾ��1: HTTP������
upstream http_backend {
    server 127.0.0.1:8080;

    keepalive 16;
}

server {
    ...

    location /http/ {
        proxy_pass http://http_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        ...
    }
}

����ʾ��2��FastCGI������
upstream fastcgi_backend {
    server 127.0.0.1:9000;

    keepalive 8;
}

server {
    ...

    location /fastcgi/ {
        fastcgi_pass fastcgi_backend;
        fastcgi_keep_conn on;
        ...
    }
}
```

# ���ؾ����㷨
* Ĭ����ѯ
```
���û��ָ���κθ��ؾ����㷨����Ĭ��Ϊ��ѯ��
���ݷ����������õ�weight���������󵽺�˷�������
```

* ip_hash
```
����upstream���С�

���ã����ڿͻ���IP��ַ�ķ�ʽ������ַ�����˷������ĸ��ؾ����㷨��IPv4��ַ��ǰ�����ֽڻ�����IPv6��ַ������Ϊhash key��
˵�������ָ��ؾ����㷨������ȷ������ͬһ���ͻ��˵��������Ǳ��ַ���ͬһ����˷����������Ǻ�˷����������á�����˷�����������ʱ���ͻ��˵����󽫻�ַ���������������

ע�⣺�����Ҫ��ʱ���Ƴ�ĳ̨����������Ҫ�ѷ��������Ϊdown��
```

* least_conn
```
����upstream���С���Ҫnginx�汾��1.3.1�������ϻ�����1.2.2

���ã����û�������ַ����������ٻ�������ĺ�˷������ϣ�ͬʱҲ�ῼ�Ƿ�������Ȩ��ֵ������ж�������ķ�������������ü�Ȩ��ѯ�ķ�ʽ��
```

* least_time
```
����upstream���С���Ҫnginx�汾��1.7.10
�﷨��ʽ��least_time header | last_byte
���ã����ͻ��˵������͵���������ƽ����Ӧʱ������ٻ�������ĺ�˷�������ͬʱҲ�ῼ�Ǻ�˷�������Ȩ�ء�����ж�������ķ�������������ü�Ȩ��ѯ�ķ�ʽ��

header����ʾ������Ӧͷ�������ѵ�ʱ�䡣
last_byte����ʾ����������Ӧ���������ѵ�ʱ�䡣
```

# nginx proxy

> ngx_http_proxy_module����������������������


* proxy_bind
```
����http��server��location���С�
�﷨��proxy_bind <address[:port]> | off
���ã�ָ��������������ӱ����������(��˷�����)��ʹ�õĵ�ַ�Ϳ�ѡ�Ķ˿�(��Ҫ1.11.2�汾)��
off����ʾȡ����ǰһ�����ü���̳е�proxy_bind���ã�������ϵͳ�Զ�����һ�����ص�IP��ַ�Ͷ˿ڡ�
```

* proxy_buffer_size
```
����http��server��location���С�
Ĭ��ֵ��proxy_buffer_size 4k|8k
���ã��������ڶ�ȡ�Ӻ�˷������յ�����Ӧ�ĵ�һ���ֵĻ����С���ⲿ��ͨ������һ��С��response header��ͨ����������С����һ���ڴ�ҳ��

�鿴�ڴ�ҳ��С��getconf PAGESIZE
```

* proxy_buffering
```
����http��server��location���С�
Ĭ��ֵ��proxy_buffering on
���ã��Ƿ�Ժ�˷���������Ӧ���л��档

������ʱ��nginx���ᾡ���ܿ�Ľ��մӺ�˷�������������Ӧ�����ҽ��䱣����proxy_buffer_size��proxy_buffersָ�������õĻ����С�
���������Ӧ����buffer�Ĵ�С��������һ���ֻᱣ���ڴ����ϵ���ʱ�ļ��С�����ʱ�ļ���proxy_max_temp_file_size��proxy_temp_file_write_sizeָ��塣

������ã���nginx�յ���Ӧʱ������ͬ�����ͻ���
```

* proxy_buffers
```
����http��server��location���С�
Ĭ��ֵ��proxy_buffers 8 4k|8k;
�﷨��proxy_buffers <number> <size>
���ã�Ϊÿһ����������number��size��С�Ļ������ڶ�ȡ�Ӻ�˷�������������Ӧ��ͨ��size��СΪһ���ڴ�ҳ��
```

* proxy_busy_buffers_size
```
����http��server��location���С�
Ĭ��ֵ��proxy_busy_buffers_size 8k|16k
���ã�������proxy_bufferingʱ����û�ж���ȫ����Ӧ������£�д���嵽��һ����Сʱ��nginxһ������ͻ��˷�����Ӧ��ֱ������С�ڴ�ֵ������ָ���������ô�ֵ�� ͬʱ��ʣ��Ļ������������ڽ�����Ӧ�������Ҫ��һ�������ݽ����嵽��ʱ�ļ����ô�СĬ����proxy_buffer_size��proxy_buffersָ�����õ��黺���С��������
```

* proxy_temp_file_write_size
```
Ĭ��ֵ��proxy_temp_file_write_size 8k|16k
���ã�ָ��һ�ο���д�뵽��ʱ�ļ������ݴ�С��
```

* proxy_max_temp_file_size
```
Ĭ��ֵ��proxy_max_temp_file_size 1024m;
���ã���proxy_buffering����Ϊonʱ��������Ӧ�Ĵ�С����proxy_buffer_size��proxy_buffers�Ĵ�С������Ӧ��һ���ֻᱻ���浽��ʱ�ļ��У����ָ����������ʱ�ļ�������С��
```

* proxy_temp_path
```
Syntax:	proxy_temp_path path [level1 [level2 [level3]]];
Default: proxy_temp_path proxy_temp;

���ã�ָ��һ��Ŀ¼���ڴ洢�Ӻ�˷��������յ���ʱ�����ļ���
```

* proxy_connect_timeout
```
Ĭ��ֵ��proxy_connect_timeout 60s;
���ã�����������ͺ�˷������������ӵĳ�ʱʱ�䡣���ܳ���75s��
```

* proxy_http_version
```
Ĭ��ֵ��proxy_http_version 1.0
���ã����ô���ʱ����ʹ�õ�HTTPЭ��汾��Ĭ����1.0����ʹ��keepaliveʱ���Ƽ���1.1
```

* proxy_ignore_client_abort
```
Ĭ��ֵ��off
���ã����ͻ��������ر�����ʱ������������ͺ�˷������������Ƿ�Ӧ�ùرա�

��ʱ���������������ͻ��˶������ر�������߿ͻ�������ϵ�����ô Nginx ���¼ 499��ͬʱ request_time �� ������Ѿ�������ʱ�䣬�� upstream_response_time Ϊ "-"

���ʹ���� proxy_ignore_client_abort on ;��ô�ͻ��������ϵ�����֮��Nginx ��ȴ���˴�����(���߳�ʱ)��Ȼ���¼ [��˵ķ�����Ϣ������־�����������˷���200���ͼ�¼ 200�������˷���5XX ����ô�ͼ�¼5XX ��
�����ʱ(Ĭ��60s�������� proxy_read_timeout ����)��Nginx�������Ͽ����ӣ���¼504��
```

* proxy_next_upstream
```
�﷨��ʽ��proxy_next_upstream error | timeout | invalid_header | http_500 | http_502 | http_503 | http_504 | http_403 | http_404 | non_idempotent | off ...;
Ĭ��ֵ��proxy_next_upstream error timeout;

���ã�ָ����ʲô����£��ŻὫ����ת������һ̨��������

error��ָ���� �ͺ�˷������������Ӵ��󡢷������󵽺�˷��������ִ��󡢴Ӻ�˷�������ȡresponse header��������
timeout��ָ���� �ͺ�˷������������ӳ�ʱ���������󵽺�˷��������ֳ�ʱ���Ӻ�˷�������ȡresponse header���ֳ�ʱ
invalid_header����˷���������һ���յĻ�������Ч����Ӧ��
http_500����˷�����������500����Ӧ״̬�롣
http_502����˷�����������502����Ӧ״̬�롣
http_503����˷�����������503����Ӧ״̬�롣
http_504����˷�����������504����Ӧ״̬�롣
http_403����˷�����������403����Ӧ״̬�롣
http_404����˷�����������404����Ӧ״̬�롣
non_idempotent��ͨ������£���һ��������÷��ݵȵķ�ʽ(POST/LOCK/PATCH)�Ѿ����͵���˷������Ļ���������ݵȵ����󲻻ᴫ�ݵ������ĺ�˷����������������ѡ��󣬽�����ȷ�ĸ���NginxҪ�����������
off�����Ὣ������һ̨��˷�������
```

* proxy_pass
```
����location��if in location��limit_except����
�﷨��ʽ��proxy_pass <URL>

���ã�����locationӳ�䵽�ĺ�˷�������Э�顢��ַ�Լ�һ����ѡ��URI����ַ������������IP��ַ�Լ�һ����ѡ�Ķ˿ڡ�
�磺proxy_pass http://localhost:8000/uri/;

1. ���proxy_passָ��ָ����URI��������ת�����˷�����ʱ����locationƥ�䵽�������URI���ᱻproxy_passָ�����ָ����URI�����滻��
	ʾ�������û����ʵ���URI��nameʱ��������ʾ127.0.0.1/remote/�µ����ݡ���ַ���в�������ʾ��
	location /name/ {
		proxy_pass http://127.0.0.1/remote/;
	}

2. ���proxy_passָ�����û��ָ��URI����������Կͻ��˷��͵���ʽ���͵���˷�������
3. ��locationʹ��������ʽָ��ʱ��proxy_passָ����治Ҫʹ��URI��
```

* proxy_pass_request_body
```
Ĭ��ֵ��on
���ã��Ƿ�ԭʼ�������崫�ݵ���˷�������
```

* proxy_pass_request_headers
```
Ĭ��ֵ��on
���ã��Ƿ�ԭʼ�����е�����ͷ���ݵ���˷�������
```

* proxy_read_timeout
```
Ĭ��ֵ��proxy_read_timeout 60s;
���ã��Ӻ�˷�������ȡ��Ӧ�ĳ�ʱʱ�䡣���ʱ����ָ���������Ķ�����֮���ʱ�䣬�����Ǵ���������Ӧ�ĳ�ʱʱ�䡣
��������ʱ����ڣ���˷�����û�д����κ����ݣ����ӽ���رա�
```
* proxy_send_timeout
```
Ĭ��ֵ: proxy_send_timeout 60s;
���ã�����������������󵽺�˷������ĳ�ʱʱ�䡣�����˷������ڸ�ʱ�����û���յ��κ����ݣ����ر����ӡ�
```

* proxy_set_header
```
�﷨��ʽ��proxy_set_header field value;
���ã������ڷ��͵���˷�����������ͷ�����¶�����������ֶΡ�
value���԰����ı����������������ߵ���ϡ�
���valueΪ�յ��ַ���������ֶβ��ᴫ�ݵ���˷��������磺proxy_set_header Accept-Encoding "";
```

* ����
```
1. $proxy_host��proxy_passָ����ָ���ĺ�˷������ĵ�ַ��
2. $proxy_port��proxy_passָ����ָ��ĺ�˷������Ķ˿ڻ�����Э���Ĭ�϶˿ڡ�
3. $proxy_add_x_forwarded_for������ͻ��˵�����ͷ�д���X-Forwarded-For�ֶΣ����µ�X-Forwarded-For�ֶ�ֵΪ��ԭ�е�X-Forwarded-For�ֶε�ֵ��$remote_addr��ֵ��ϣ�����֮��ʹ�ö��ŷָ�������ͻ��˵�����ͷ��û��X-Forwarded-For�ֶΣ���$proxy_add_x_forwarded_for��ͬ��$remote_addr��
```