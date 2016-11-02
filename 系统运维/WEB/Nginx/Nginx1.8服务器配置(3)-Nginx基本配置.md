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

```


