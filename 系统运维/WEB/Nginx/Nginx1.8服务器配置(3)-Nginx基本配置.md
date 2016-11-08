# ulimit����
```
1G�ڴ�ķ�������ſ��Դ�Լ10w���ļ���������
LinuxϵͳĬ�ϵĴ򿪵��ļ�����1024�������������У����ֵ���õ�̫С�����������ֵ�������ʾtoo many open files��

����1���޸�/etc/security/limits.conf
* soft nofile 1000000
* hard nofile 1000000

����2���޸�/etc/profile�ļ�
ulimit -n 65535
�������ַ����������Ժ��û����µ�¼�¾Ϳ����ˣ�����Ҫ����ϵͳ��

����3����ʱ���ã�ֻ��Ե�ǰ������Ч��
[root@vm3 tcmalloc]# ulimit -SHn 1000000
[root@vm3 tcmalloc]#
```

# main��������
```
user <user> [group]��ָ��nginx worker���̵�ӵ���ߺ������顣���ʡ����group����Ĭ�ϵĵ�group��user��ͬ����user  www www

pid��ָ��nginx pid�ļ��Ĵ洢λ�á���pid /var/run/nginx.pid�����ָ����·�����·�����������nginx��prefix��

daemon on|off��Ĭ��ֵΪon��ָ��nginx�Ƿ���daemon�ķ�ʽ���С�ͨ������Ҫ�޸ġ�

master_process on|off��Ĭ��ֵΪon��on��ʾ����һ��master���̺Ͷ��worker���̡�off��ʾֻ����master���̣�������worker���̡�

worker_priority <number>��ָ��worker���̵����ȼ���Ĭ��ֵΪ0����Χ��-20��19��ֵԽС�����ȼ�Խ�ߡ�

worker_processes <number>��ָ������worker���̵�������Ĭ��ֵΪ1. ͨ������Ϊ��CPU������һ�¼��ɡ���ȡCPU��������cat /proc/cpuinfo  | grep processor | wc -l

worker_cpu_affinity <cpumask>������CPU��worker���̵��׺�������worker���̰󶨵�CPU�ϡ�
	ʾ����
	worker_processes 4;
	worker_cpu_affinity 0001 0010 0100 1000;
	�����趨��
	��1��cpu�ж��ٸ��ˣ����м�λ����1�����ں˿�����0�����ں˹ر�
	��2��worker_processes��࿪��8����8���������ܾͲ����������ˣ������ȶ��Ի��ĸ��ͣ����8�����̹�����
		worker_processes 8;
		worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
		
		2��CPU������8���̣�
		worker_processes  8;  
		worker_cpu_affinity 01 10 01 10 01 10 01 10;
		
		8��CPU������2���̣�
		worker_processes  2;
		worker_cpu_affinity 10101010 01010101;
		˵����10101010��ʾ�����˵�2,4,6,8�ںˣ�01010101��ʾ��ʼ��1,3,5,7�ں�

worker_rlimit_nofile <number>��ָ��һ��worker���̿��Դ򿪵��ļ�������������worker_connections���ܳ�����ֵ��

error_log file|stderr|syslog:server-address[,parameter-value] [debug | info | notice | warn | error | crit | alert | emerg]��ָ��error log�Ĵ洢λ�á���������main��http��mail��stream��server��location�����С����û��ָ����־�ȼ�����Ĭ�ϵ���־�ȼ�Ϊerror��
		
```

* main��������ʾ��
```
user  www www;
worker_processes  4;
worker_cpu_affinity 0001 0010 0100  1000;

worker_rlimit_nofile 1000000;

error_log  logs/error.log  notice;

pid        /var/run/nginx.pid;
google_perftools_profiles /usr/local/source/nginx18/tcmalloc/tcmalloc;

```

# events��������
```
use��ָ����������ķ�ʽ�����õķ�ʽ�У�select��poll��kqueue��������FreeBSD4.1+��OpenBSD 2.9+��MasOS X,NetBSD 2.0����epoll��������Linux2.6+���ϵ��ںˣ���/dev/poll��Solaris 7 11/99+��HP/UX 11.22+����eventport��Solaris 10

multi_accept on|off��Ĭ��ֵΪoff��on��ʾһ��worker����һ�ν��ն������off��ʾһ��worker����һ��ֻ����һ������

accept_mutex on|off��Ĭ��ֵΪon��
	������Ϊonʱ�����worker���̽��ᰴ��˳������µ����ӣ�����ֻ��һ��worker���̻ᱻ���ѣ�������worker���̽����������˯��״̬��
	������Ϊoffʱ�����е�worker���̽��ᱻ֪ͨ������ֻ��һ��worker���̿��Ի��������ӣ�������worker���̻����½�������״̬�����Ϊ����Ⱥ���⡱��
	�����վ�������Ƚϴ󣬿��Թر�����
	
worker_connections <number>��Ĭ��ֵΪ512.ָ��һ��worker������ͬʱ�������������
	* ͨ��worker_processes��worker_connections�ܹ���������ͻ�����������
    max_clients=worker_processes * worker_connections
    * �ڷ���������У����ͻ���������:
    max_clients=worker_processes * worker_connections/4
    ԭ��Ĭ������£�һ���������Է��������������ӣ�Nginxʹ������ͬһ�����е�FDS���ļ������������������η�������
    
	���յĽ��ۣ�http 1.1Э���£����������Ĭ��ʹ��������������,��˼��㷽����
    * nginx��Ϊhttp��������ʱ��
    max_clients = worker_processes * worker_connections/2
    
	* nginx��Ϊ��������������ʱ��
    max_clients = worker_processes * worker_connections/4
    
	* clients���û�����
	ͬһʱ���clients(�ͻ�����)���û�������������ģ���һ���û�������һ������ʱ����������ȵģ����ǵ�һ���û�Ĭ�Ϸ��Ͷ�����������ʱ��clients�������û���*Ĭ�Ϸ��͵����Ӳ������ˡ�
	
debug_connection <address>|<cidr>|unix: û��Ĭ��ֵ��Ϊָ���Ŀͻ��˿���debug log�������Ŀͻ��˽���ʹ��error_log�����á���Ҫ�ڱ���ʱ����--with-debugѡ��磺
    debug_connection 127.0.0.1;
    debug_connection 172.17.100.0/24;
    debug_connection localhost;
```

* event��������ʾ��
```
events {
    use epoll;
    accept_mutex off;
    multi_accept on;
    worker_connections  200000;
}
```

# http��������

> http�������һ������server���飬server������԰���һ������location���顣


ע�⣺���²������û������˵�����������http��server��location���С�

* client_body_buffer_size 
```
Ĭ��ֵΪ8K(32bit)��16K(64bit).�������ڶ�ȡ�ͻ���������Ļ����С������ͻ��˵���������������õĻ����С��������������򲿷�������ᱻд�뵽��ʱ�ļ���(client_body_temp_path)��
```

* client_body_temp_path
```
�﷨��ʽ��client_body_temp_path <path> [level1 [level2 [level3]]]
���ã�ָ���洢�ͻ����������Ŀ¼�����Ϊ3����Ŀ¼�ṹ��
```

* client_body_timeout
```
Ĭ��Ϊ60s��ָ����ȡ�ͻ���������ĳ�ʱʱ�䡣ֻ���������ɹ��Ķ������ڼ�Ż�����������������������������崫���ڼ䡣��������ʱ����ڿͻ���û�з����κ����ݣ���������ᷢ��408(Request Timeout)������ͻ��ˡ�
```

* client_header_buffer_size
```
Ĭ��Ϊ1K.����http��server�Ρ��������ڶ�ȡ�ͻ�������ͷ�Ļ����С��
```

* large_client_header_buffers
```
����http��server���С�
�﷨��ʽ��large_client_header_buffers <number> <size>
Ĭ��ֵΪ��large_client_header_buffers 4 8k
���ã�ָ�����ڶ�ȡ��Ŀͻ�������ͷ�Ļ����С��ָ��number��size��С�Ļ��档

����ͻ��������еĴ�С����һ��buffer(size)�Ĵ�С����᷵��414(Request-URI Too Large)������ͻ��ˡ�
����ͻ�������ͷ�Ĵ�С����һ��buffer(size)�Ĵ�С����᷵��400(Bad Request)������ͻ��ˡ�
```

* clent_header_timeout
```
����http��server�Ρ�
Ĭ��ֵ60s�����ڶ����ȡ�ͻ�������ͷ�ĳ�ʱʱ�䡣����ͻ��������ʱ�����û�з�����������ͷ����������ᷢ��408(Request Timeout)������ͻ��ˡ�
```

* client_max_body_size
```
Ĭ����1m��
��������Ŀͻ��������������С���ô�С������ͷ��Content-Length�ֶ��С���������峬���ô�С����ᷢ��413(Request Entity Too Large)������ͻ��ˡ�
����Ϊ0�����ʾ�رտͻ����������С��顣
```

* default_type
```
Ĭ��ֵΪ��text/plain
ָ����Ӧʱ��Ĭ�ϵ�MIME���͡�
```

* etag
```
Ĭ��Ϊon��
���ã��Ƿ�Ϊ��̬��Դ��response header�����ETag�ֶΡ�
```

* if_modified_since
```
Ĭ��ֵΪexact��
���ã�ָ����αȽ��ļ����޸�ʱ�������ͷ��If-Modified-Since�ֶε�ʱ�䡣

off������ͷ�е�If-Modified-Since�ֶλᱻ���ԡ�
exact���ļ����޸�ʱ���If-Modified-Since�ֶα�����ȫƥ�䡣
before���ļ����޸�ʱ��ҪС�ڻ����If-Modified-Since�ֶε�ʱ�䡣


If-Modified-Since�Ǳ�׼��HTTP����ͷ��ǩ���ڷ���HTTP����ʱ����������˻���ҳ�������޸�ʱ��һ�𷢵�������ȥ��������������ʱ�����������ʵ���ļ�������޸�ʱ����бȽϡ�
���ʱ��һ�£���ô����HTTP״̬��304���������ļ����ݣ����ͻ��˽ӵ�֮�󣬾�ֱ�Ӱѱ��ػ����ļ���ʾ��������С�
���ʱ�䲻һ�£��ͷ���HTTP״̬��200���µ��ļ����ݣ��ͻ��˽ӵ�֮�󣬻ᶪ�����ļ��������ļ���������������ʾ��������С�

�����Ҫ�ͻ���ÿһ�����󶼲�ʹ�û��棬����Խ�etag����Ϊoff��if_modified_since����Ϊoff��
```

* keepalive_disable
```
���ã���ָ����������ر�Keepalive��Ĭ��ֵΪkeepalive_disable msie6
�﷨��ʽ��keepalive_disable none | browser ...;
browser��ʾҪ����keepalive����������ͣ�����ָ�������
none����ʾ���е������������keepalive��

```

* keepalive_requests
```
Ĭ��ֵΪ100.
ָ��һ��http�������������͵������������
```

* keepalive_timeout
```
�﷨��ʽ��keepalive_timeout <timeout> [header_timeout]
Ĭ��ֵ��75s��
���ã�ָ������ͬһ���ͻ��˵�����������HTTP����֮��ĳ�ʱʱ�䡣
��һ������ָ��������������http����֮��ĳ�ʱʱ�䣬������ʱ��󣬷��������������ر����ӡ�
�ڶ�������ָ��������Ӧͷ������"Keep-Alive: timeout=time"�е�timeֵ�����ͷ������һЩ����������ر����ӡ�
```

* limit_rate
```
Ĭ��ֵΪ0.��ʾ�ر��������ơ�
���ã����ƴ������ʡ���λ��bytes/s������ǵ�������Ĵ������ʡ�����Ƕ��������������Ϊ�����������������ʡ�
```

* limit_rate_after
```
Ĭ��ֵΪ0.
���ã�ָ���������������ʱ���ſ�ʼ�����������ơ�
```

* listen
```
����server���С�
ָ�������ĵ�ַ��(��)�˿ڡ�
�磺listen 80������listen 172.17.100.3:80
```

* server_name
```
����server���С�
�﷨��ʽ��server_name <name> [name] ...
���ã������������������֡�
��һ�����ֽ����Ϊ���ķ��������ơ�
�磺
server_name  www.felix.com felix.com
server_name *.felix.com
server_name .felix.com
```
* resolver
```
�﷨��ʽ��resolver address ... [valid=time]
���ã�ָ�����ڽ���upstream�е���������IP��ַ��һ������DNS��������
��resolver 172.17.100.1:53�����û��ָ���˿ڣ���Ĭ��Ϊ53�˿ڡ�
valid��ʾnginx���Ի���೤ʱ�䡣
```

* resolver_timeout
```
Ĭ��Ϊ30s��ָ�����ƽ����ĳ�ʱʱ��
```


* root
```
ָ������ĸ�Ŀ¼��Ĭ��ֵΪroot html��
```

* server_tokens
```
Ĭ��ֵΪon��
���ã��ڴ�����Ϣ��������ӦͷServer�ֶ����Ƿ���ʾnginx�İ汾��Ϣ

on����ʾ��ʾ�汾��Ϣ
off����ʾ����ʾ�汾��Ϣ��
string����ʾ��string�滻����1.9.13�����Ժ�İ汾���á�
```

* sendfile
```
Ĭ��Ϊoff��
���ã��Ƿ�����sendfile���á�sendfile���ں�������ļ��ĸ��ƣ��������nginx�����ܡ�һ������Ϊon
```

* tcp_nopush
```
Ĭ��ֵΪoff��
ֻ�е�sendfile����Ϊonʱ����ѡ��������á������ǣ�Ӧ�ó�����������ݰ����������ͳ�ȥ���ȵ����۵�һ������ʱ���Ż�һ���Է��ͳ�ȥ��������Ч�Ľ������ӵ����

��sendfile����Ϊonʱ����ѡ��Ҳ�������Ϊon��
```

* tcp_nodelay
```
Ĭ��ֵΪon��
���ã����ӳٵķ���Ӧ�ó�����������ݡ������ǵȴ����۵�һ������ʱ�ڷ��͡�

tcp_nodelay��tcp_nopush�ǻ���ġ�


ͨ���������ã�����������ܣ�
sendfile 	on;
tcp_nopush 	on;
tcp_nodelay	off;
```

* types
```
�﷨��ʽ��
	types {
		mime-type filename-extensions;
		...
	}
���ã�ӳ���ļ�����չ��ָ����MIME���͡��ļ�����չ�ǲ����ִ�Сд�ġ�

ʾ����
types {
	application/octet-stream bin exe dll;
	application/octet-stream deb;
	application/octet-stream dmg;
}
```

* internal
```
ֻ������location���С�
���ã�ָ��������locationֻ�������ڲ������󣬶����ⲿ��������ֱ�ӷ���404(Not Found)��

���µ������ʾ�ڲ�����
1. ��error_page��index��random_index��try_files��Щָ���ض��������
2. ��rewriteָ����д������
```

* error_page
```
�﷨��ʽ��error_page <code> ... [=[response]] <uri>;
���ã�Ϊָ����һ���������������ʾָ����URI��URI���԰���������
����������һ���ڲ����ض���ָ����URI�����ҽ��ͻ��˵����󷽷���ΪGET(����GET��HEAD����֮������з���)��

code����ʾ��Ӧ״̬�롣
response����ʾ�ı���Ӧ״̬��Ϊָ������Ӧ״̬�롣
uri�������վ���Ŀ¼root��·������������·����

ʾ����
error_page 404             /404.html;
error_page 500 502 503 504 /50x.html;


* �ı���Ӧ״̬��
	������=response�ı���Ӧ״̬��
	ʾ����error_page 404 =200 /test.html;

* �ض���ָ����URL
	ʾ����error_page 404 http://www.felix.com;
	��������£��������һ��302(��ʱ�ض���)��״̬����ͻ��ˡ�
	error_page 404 =301 http://www.felix.com;
	�����ͻ����һ��301(�����ض���)��״̬����ͻ��ˡ�

* ����error_page��������location
	location / {
		error_page 404 = @fallback;
	}
	location @fallback {
		proxy_pass http://backend;
	}
```

* alias
```
����location�����С�

���ã�ʵ��URI���ļ�ϵͳ·��֮���ӳ�䡣�Ὣ�û��������Ŀ¼�滻Ϊalias�������Ŀ¼��
```

* index
```
��������nginx��Ĭ����ҳ�ļ��������ԡ�/����β�����󡣲���˳��Ϊindex�������˳������ҵ����򲻻������һ����
```

# location
* location˵��
```
����server��location���С�
�﷨��ʽ���£�
location [ = | ~ | ~* | ^~ ] uri { ... }
location @name { ... }


location��Ϊ���֣���ͨlocation������location��
=��^~��@�Լ����κ�ǰ׺�Ķ�������ͨlocation��
~����ʾ��������location�����ִ�Сд��
~*����ʾ��������location�������ִ�Сд��

```

* locationƥ��˳��
```
location��ƥ��˳����ƥ����ͨ��location����ƥ������location��

* ��ͨlocation��ƥ��˳�����ǰ׺ƥ�䡣�ͳ����������ļ��е��Ⱥ�˳���޹ء�
	ʾ��:
	location /prefix ��location /prefix/test������û�����Ϊ/prefix/test/a.html��������location�����㣬�������ǰ׺ƥ�䣬���ƥ��/prefix/test�����

* ��ͨlocation�������ǰ׺ƥ�������󣬻�Ҫ��������location���м���ƥ�䡣
˵���������������������locationҲ��ƥ���ϵģ�������location�Ḳ����ͨlocation�����ǰ׺ƥ�䡣�������locationû��ƥ���ϣ�������ͨlocation�����ǰ׺ƥ��Ϊ�����

* ����location��ƥ��˳�򣺸����������ļ��г��ֵ��Ⱥ�˳��ƥ��ġ�����ֻҪƥ�䵽һ������location�󣬾Ͳ��ٿ��Ǻ��������location�ˡ�

* ͨ������ǣ�ƥ��������ͨlocation�󣬻�Ҫ�������location�����ǿ��Ը���Nginx��ƥ�䵽����ͨlocation�󣬾Ͳ�Ҫ����ƥ������location�ˡ�Ҫ������һ�㣬��Ҫ����ͨlocationǰ����ϡ�^~�����ż��ɡ�

* ��������˵��^~������ֹ������������location�⣬������ʹ�á�=������ֹ������������location����=���͡�^~�����������ڣ�^~��Ȼ�������ǰ׺ƥ����򣬶�=��ǿ�������ϸ�ƥ�䡣

* ��һ�ֿ�����ֹ������������location�⣬����һ�ַ�ʽ�����ǣ���ͨlocation�����ǰ׺ƥ��ǡ�þ����ϸ�ȷƥ�䡣����Ҳ��ֹͣ������������location��
```

# gzip�������
* gzip
```
���ã��Ƿ��response����������gzipѹ�����ܡ�
on����ʾ���á�
off����ʾ�����á�
Ĭ��Ϊoff��
```

* gzip_buffers
```
�﷨��ʽ��gzip_buffers <number> <size>
���ã�ָ��number��size��С�Ļ�������ѹ��response��
Ĭ��ֵ��gzip_buffers 32 4k|16 8k;
```

* gzip_comp_level
```
���ã�ָ��ѹ���ȼ���Ĭ��Ϊ1����Χ��1��9
```

* gzip_disable
```
�﷨��ʽ��gzip_disable <regexp>
���ã�ʹ��������ʽ�Կͻ�������ͷ��User-Agent�ֶν���ƥ�䣬���ƥ�䵽�������Ӧ���ݲ�����gzipѹ�����ܡ�
�磺gzip_disable "MSIE [4-6]\."������ƥ�䵽MSIE 4.*��MSIE 6.*�����ǲ���ƥ�䵽MSIE 6.0; ... SV1
```

* gzip_min_length
```
���ã�ָ�����ᱻѹ������Ӧ���ݵ���С���ȡ�������Ӧͷ��Content-Length�ֶΡ�Ĭ����20���ֽڡ�
```

* gzip_http_version
```
���ã�ָ����Ҫ��ѹ����HTTP����С�汾����1.0��1.1����ֵ��Ĭ����1.1
```

* gzip_types
```
�﷨��ʽ��gzip_types mime-type ...;
Ĭ��ֵ��gzip_types text/html;

���ã���ָ����MIME���ͽ���ѹ����*����ƥ�����е�MIME���͡�text/html�ܻᱻѹ����
```

* gzip_vary
```
Ĭ��ֵ��off��
���ã���HTTP��Ӧͷ������"Vary: Accept-Encoding"�ֶΡ�

Vary�����ã����ߴ���������������ְ汾����Դ��ѹ���ͷ�ѹ�����������ڱ���һЩ������������ȷ�ؼ��Content-Encoding��ͷ�����⡣
�����������Ϊ��ͬ��Accept-Encoding�洢�����������ǲ�һ���ġ�֧��Accept-Encoding����洢����gzip��deflate��ʽ����֧��Accept-Encoding��洢������ҳԴ�롣

��ѡ��һ����Ҫ������gzip_vary on;
```

* gzip_proxied
```
Ĭ��ֵΪoff��

Nginx��Ϊ��������ʱ�����ã�����ĳЩ�����Ӧ���������Ƿ��ڶԴ��������Ӧ������gzipѹ�����Ƿ�ѹ��ȡ��������ͷ�еġ�Via���ֶΣ�ָ���п���ͬʱָ�������ͬ�Ĳ������������£�
off - Ϊ���еĴ�������ر�ѹ������
expired - ����ѹ�������headerͷ�а��� "Expires" ͷ��Ϣ
no-cache - ����ѹ�������headerͷ�а��� "Cache-Control:no-cache" ͷ��Ϣ
no-store - ����ѹ�������headerͷ�а��� "Cache-Control:no-store" ͷ��Ϣ
private - ����ѹ�������headerͷ�а��� "Cache-Control:private" ͷ��Ϣ
no_last_modified - ����ѹ��,���headerͷ�в����� "Last-Modified" ͷ��Ϣ
no_etag - ����ѹ�� ,���headerͷ�в����� "ETag" ͷ��Ϣ
auth - ����ѹ�� , ���headerͷ�а��� "Authorization" ͷ��Ϣ
any - ����������ѹ��
```

* gzip����ʾ��
```
gzip  on; 
gzip_buffers 64 8k;     
gzip_comp_level 6;
gzip_min_length 10k;
gzip_disable "MSIE [4-6]\.";
gzip_types text/plain text/css text/xml application/javascript;
gzip_http_version 1.1;
gzip_vary on; 
```

# log
* access_log
```
�﷨��ʽ��
access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]];
access_log off;

���ã�ָ���û����ʵ���־��¼λ�á�
off����ʾ�ر���־��¼���ܡ�
path��ָ����־�洢λ�á���¼��syslog��д�����£�
	error_log syslog:server=172.17.100.1 debug
	access_log syslog:server=172.17.100.1:12345,facility=local7,tag=nginx,serverity=info combined
format��ָ����¼��־ʱʹ�õ�log_format
if��������ָ����������Ϣ��¼���������if���������ֵΪ0�����ǿյ��ַ������򲻻ᱻ��¼��
```

* log_format
```
����http���С�

�﷨��ʽ��log_format <name> <string> ...
name����ʾ��access_log���õ����֡�
string����ʾҪ���õı�������
	$bytes_sent�����͵��ͻ��˵��ֽ�����������Ӧͷ��
	$body_bytes_sent�����͵��ͻ��˵��ֽ�������������Ӧͷ��
	$content_length������ͷ�е�Content-Length�ֶΡ�
	$content_type������ͷ��Content-Type�ֶΡ�
	$connection���ͻ��˵��������кš�
	$connection_requests��ͨ�������ӷ��͵ĵ�ǰ��������
	$request_length���ͻ��˷��͵�HTTP����ĳ���(���������С�����ͷ��������)��
	$request_time����ʾ�������������ѵ�ʱ��(��λ���룬������ʾ�����뼶)�����ʱ���ʾ���ǴӶ�ȡ�ͻ��˷���������ĵ�һ���ֽڿ�ʼ�������һ���ֽڷ��͵��ͻ��˺����־д�������ѵ���ʱ�䡣
	$status����Ӧ״̬�롣
	$time_iso8601��ʹ��ISO 8601�ı�׼��ʽ��ʾ�ı���ʱ�䡣2016-11-03T13:00:01+08:00
	$time_local��ͨ����־��ʽ��ʾ�ı���ʱ�䡣03/Nov/2016:13:00:01 +0800
	$document_root����ǰ�����root��aliasָ���ֵ��
	$document_uri���û������URI��
	$host���û����ʵ�������˳�����£������е�������������ͷ��Host�ֶΡ�ƥ�������server name��
	$hostname����������
	$https�����ʹ��sslģʽ����Ϊon������Ϊ�ա�
	$nginx_version��nginx�İ汾��
	$query_string����ѯ�ַ�����
	$remote_addr���ͻ��˵�ַ
	$remote_port���ͻ��˶˿�
	$remote_user�����������֤���û���
	$request��������ԭʼ�����е����ݡ������а��������󷽷��������URL��HTTPЭ��汾��
	$request_body��������
	$request_uri�������������URI��
	$request_method�����󷽷���
	$scheme�������scheme����http��https
	$server_addr����������ķ������ĵ�ַ��
	$server_port����������ķ������Ķ˿ڡ�
	$server_name����������ķ����������ơ�
	$server_protocol�������Э�顣��HTTP/1.0��HTTP/1.1��HTTP/2.0
	$http_<name>��name��ʾ�������������ͷ�ֶ����ơ�����name��Сд�ģ����»�������������ͷ�е����ۺš���http_user_agent
	
```

* Nginx���б����б�
[Nginx�����б�](http://nginx.org/en/docs/varindex.html)


* log����ʾ��
```
log_format common '[$time_iso8601] $remote_addr $remote_user "$request" $body_bytes_sent $status "$http_referer" "$http_user_agent"';
access_log  logs/access.log  common;
```

# ���ʿ���

> ����http��server��location���С�


* allow
```
�﷨��ʽ��allow <address> | <cidr> | all;
address����ʾ����һ��IP��ַ����172.17.100.1
cidr����ʾ����һ��CIDR��ַ�顣��172.17.100.0/24
all����ʾ�������е�ַ��

ʾ����
allow 172.17.100.1;
allow 172.17.100.0/24;
allow all;
```

* deny
```
deny <address> | <cidr> | all;
address����ʾ����һ��IP��ַ����172.17.100.1
cidr����ʾ����һ��CIDR��ַ�顣��172.17.100.0/24
all����ʾ�������е�ַ��

ʾ����
deny 172.17.100.1;
deny 172.17.100.0/24;
deny all;
```

* allow��deny�Ĺ���
```
allow��deny���ݳ����������е�˳�����ƥ�䣬���ƥ��������������û��ƥ��������
```

* satisfy
```
�﷨��ʽ��satisfy all | any;

Ĭ��Ϊall��

all����ʾ����ͨ����֤��allow��������ʡ�(����ͬʱ����)
any����ʾֻҪ������֤������allow�Ϳ��ԡ�(������һ����)

```

* ���úڰ�����
```
ָ�����Է��ʷ������İ���������

http {
	...
	include whitelist.conf;
}


cat whitelist.conf

allow 172.17.100.0/24;
allow 192.168.1.0/24;
deny all;
```

# ��֤

> ����http��server��location���С�


* auth_basic
```
�﷨��ʽ��auth_basic <string> | off
Ĭ�ϣ�off

off����ʾ��ʹ����֤��
string����ʾ��֤��realm�����԰���������

```

* auth_basic_user_file
```
���ã�ָ������û���֤��Ϣ���ļ������ļ������԰���������
���ļ��ĸ�ʽ���£�
# comment
name1:password1
name2:password2:comment
name3:password3


����ֱ����apache��htpasswd�������ɸ��ļ���
```

* htpasswd
```
Usage:
        htpasswd [-cmdpsD] passwordfile username
        htpasswd -b[cmdpsD] passwordfile username password
        htpasswd -n[mdps] username
        htpasswd -nb[mdps] username password
 -c  Create a new file.
 -n  Don't update file; display results on stdout.
 -m  Force MD5 encryption of the password.
 -d  Force CRYPT encryption of the password (default).
 -p  Do not encrypt the password (plaintext).
 -s  Force SHA encryption of the password.
 -b  Use the password from the command line rather than prompting for it.
 -D  Delete the specified user.
˵����
-c������һ���µ������ļ������ڵ�һ��ʹ�á�
-n���������ļ���ֻ����ʾ�����
-m��ʹ��md5���ܡ�
-d��ʹ��CRYPT���ܡ�Ĭ�Ϸ�ʽ��
-p�������ܡ����Ĵ�š�
-s��ʹ��SHA���ܡ�
-b�����������л�ȡ���룬�����Ǵӽ���ʽ����ʾ�л�ȡ��
-d��ɾ��ָ�����û���


ʾ����
[root@vm3 auth]# htpasswd -c /usr/local/source/nginx18/auth/users nginx_test01
New password: 
Re-type new password: 
Adding password for user nginx_test01
[root@vm3 auth]# cat users 
nginx_test01:iExwE35H1j7oA
[root@vm3 auth]# 
```

* ����ʾ��
```
location /felix {
	root html;
	index index.html; 

	allow 172.17.100.1;
	deny all;
	satisfy any;

	auth_basic "need auth";
	auth_basic_user_file ../auth/users;
}

```

# AutoIndex

> ����http��server��location���С����û���ҵ�indexָ����������ļ������г�Ŀ¼�µ����ݡ�


* autoindex
```
�﷨��autoindex on|off
Ĭ��ֵ��off
���ã��Ƿ�����autoindex���ܡ�
```

* autoindex_exact_size 
```
�﷨��autoindex_exact_size on|off
Ĭ��ֵ��on
���ã��Ƿ���ʾ�ļ���׼ȷ��С��������ʹ��KB/MB/GB��
```

* autoindex_format
```
�﷨��ʽ��autoindex_format html|xml|json|jsonp
Ĭ��ֵ��html
���ã�ָ��Ŀ¼��ʾ��ʽ��
```

* autoindex_localtime
```
�﷨��ʽ��autoindex_localtime on|off
Ĭ��ֵ��off
���ã��Ƿ��Ա���ʱ����ʾ��
```

* ����ʾ��
```
autoindex on;
autoindex_format html;
autoindex_exact_size on;
autoindex_localtime on;
```

# stub_status
* ����ʾ��
```
˵�����ڱ���ʱ����Ҫ����--with-http_stub_status_module

location /status {
	stub_status;
	allow 172.17.100.0/24;
	deny all;
}
```

* �������
````
Active connections: 1338 
server accepts handled requests
 15910 15910 15138 
Reading: 0 Writing: 528 Waiting: 810 


Active Connections����ǰ��Ŀͻ��˵�������������Waiting״̬�����ӡ�
accepts���ܹ����յĿͻ�����������
handled���Ѿ�����Ŀͻ��˵���������ͨ������£�����ֵ��accepts��ֵ��ȣ����ǳ�������Դ���ƣ���worker_connections�����ơ�
requests���ܵĿͻ��˵���������
Reading����ǰnginx���ڶ�ȡ����ͷ����������
Writing����ǰnginx����׼����Ӧ���ݰ����ͻ��˵���������
Waiting����ʾ���ڵȴ���һ���������Ŀ��пͻ�����������ͨ�����ֵ���ڣ�active - reading - writing
```