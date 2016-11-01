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
```

```

