# Apache2.2Դ�밲װ
## �������
* apr��apr-util
��Ҫapr��apr-util�İ汾Ϊ1.2���ϡ�

* openssl��openssl-devel
����SSL/TLS���ṩhttps֧�֡�

* zlib��zlib-devel
�ṩѹ��֧�֡�

```
[root@vm3 ~]# yum install -y apr apr-util zlib zlib-devel openssl openssl-devel
```

## �༭��װhttpd 2.2.31
### ��̬����
>��ν�ľ�̬������ָ���е�ģ�鶼�����httpd����ļ��С��ڱ���ʱ����Ҫָ��--enable-mods-shared='module-name'����modulesĿ¼�в�����module.so���ļ���

```
[root@vm3 apache]# tar -jxf httpd-2.2.31.tar.bz2 
[root@vm3 apache]# cd httpd-2.2.31
[root@vm3 httpd-2.2.31]# ./configure --prefix=/usr/local/source/apache22 --enable-so --enable-ssl --enable-rewrite --enable-cgi --enable-deflate --enable-expires --enable-headers --with-zlib --with-mpm=worker --enable-modules=all
[root@vm3 httpd-2.2.31]# make
[root@vm3 httpd-2.2.31]# make install
```

�鿴�����ģ�飺httpd -M
```
[root@vm3 bin]# ./httpd -M
httpd: apr_sockaddr_info_get() failed for vm3.felix.com
httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1 for ServerName
Loaded Modules:
 core_module (static)
 authn_file_module (static)
 authn_default_module (static)
 authz_host_module (static)
 authz_groupfile_module (static)
 authz_user_module (static)
 authz_default_module (static)
 auth_basic_module (static)
 include_module (static)
 filter_module (static)
 deflate_module (static)
 log_config_module (static)
 env_module (static)
 expires_module (static)
 headers_module (static)
 setenvif_module (static)
 version_module (static)
 ssl_module (static)
 mpm_worker_module (static)
 http_module (static)
 mime_module (static)
 status_module (static)
 autoindex_module (static)
 asis_module (static)
 cgid_module (static)
 cgi_module (static)
 negotiation_module (static)
 dir_module (static)
 actions_module (static)
 userdir_module (static)
 alias_module (static)
 rewrite_module (static)
 so_module (static)
Syntax OK
[root@vm3 bin]# 

```

### ��̬����(DSO)
>��̬�����ģ�����ڱ���ʱʹ��--enable-mods-shared='module-name'������modulesĿ¼������module.so���ļ����������ļ�����Ҫʹ��loadmodule����ģ�顣
>--with-mpm=worker��ʾ��MPM�����һ����̬ģ�顣MPMģ������ǣ�prefork��worker��event�����û�и�ѡ���Ĭ��Ϊpreforkģ�顣

```
[root@vm3 apache]# tar -jxf httpd-2.2.31.tar.bz2 
[root@vm3 apache]# cd httpd-2.2.31
[root@vm3 httpd-2.2.31]# ./configure --prefix=/usr/local/source/apache22 --enable-so --enable-ssl --enable-rewrite --enable-cgi --enable-deflate --enable-expires --enable-headers --with-zlib --with-mpm=worker --enable-mods-shared=all
[root@vm3 httpd-2.2.31]# make
[root@vm3 httpd-2.2.31]# make install
```

```
[root@vm3 bin]# ./httpd -M
httpd: apr_sockaddr_info_get() failed for vm3.felix.com
httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1 for ServerName
Loaded Modules:
 core_module (static)
 mpm_worker_module (static)
 http_module (static)
 so_module (static)
 authn_file_module (shared)
 authn_dbm_module (shared)
 authn_anon_module (shared)
 authn_dbd_module (shared)
 authn_default_module (shared)
 authz_host_module (shared)
 authz_groupfile_module (shared)
 authz_user_module (shared)
 authz_dbm_module (shared)
 authz_owner_module (shared)
 authz_default_module (shared)
 auth_basic_module (shared)
 auth_digest_module (shared)
 dbd_module (shared)
 dumpio_module (shared)
 reqtimeout_module (shared)
 ext_filter_module (shared)
 include_module (shared)
 filter_module (shared)
 substitute_module (shared)
 deflate_module (shared)
 log_config_module (shared)
 log_forensic_module (shared)
 logio_module (shared)
 env_module (shared)
 mime_magic_module (shared)
 cern_meta_module (shared)
 expires_module (shared)
 headers_module (shared)
 ident_module (shared)
 usertrack_module (shared)
 unique_id_module (shared)
 setenvif_module (shared)
 version_module (shared)
 ssl_module (shared)
 mime_module (shared)
 dav_module (shared)
 status_module (shared)
 autoindex_module (shared)
 asis_module (shared)
 info_module (shared)
 cgid_module (shared)
 cgi_module (shared)
 dav_fs_module (shared)
 vhost_alias_module (shared)
 negotiation_module (shared)
 dir_module (shared)
 imagemap_module (shared)
 actions_module (shared)
 speling_module (shared)
 userdir_module (shared)
 alias_module (shared)
 rewrite_module (shared)
Syntax OK
[root@vm3 bin]# 

```

### ����ѡ��˵��
```
--prefix����װĿ¼
--sysconfdir:�����ļ�Ŀ¼
--enable-so������DSO����̬������󣩵�֧�֡���̬װ��ģ��
--enable-ssl��֧��https�Ĺ���
--enable-rewrite��֧��rewrite����
--enable-cgi��֧��CGI�ű�����
--enable-deflate���ṩ�����ݵ�ѹ���������֧�֣�һ��html��js��css�Ⱦ�̬���ݣ�ʹ�ô˲������ܻ�����ߴ����ٶȣ����������߷������顣�����������У�����apache���ŵ�һ����Ҫѡ��֮һ��
--enable-expires����������ͨ�������ļ�����HTTP�ġ�Expires�����͡�Cache-Control����ͷ���ݣ�������վͼƬ��js��css�����ݣ��ṩ�ڿͻ�����������������á�����apache���ŵ�һ����Ҫѡ��֮һ��
--enable-headers���ṩ�����HTTP����ͷ�Ŀ���
--with-zlib��ѹ�����ܵĺ�����
--with-pcre��perl������İ�װĿ¼
--enable-modules=most��most��ʾ���볣�õ�ģ�飬all��ʾ�������е�ģ��
--with-mpm=worker������Ĭ�����õ�MPMģʽΪworker
--enable-mods-shared=all����̬����ģ�顣
```

# MPMģ�����
>MPM:Multi-Processing Modules��MPM���ڰ�����ӿڡ��������󡢵����ӽ��̴�������ȡ�

## prefork
>prefork����Ԥ�������̵ķ�ʽ�����û�����һ�����̴���һ���û�������

```
# prefork MPM
# StartServers: number of server processes to start
# MinSpareServers: minimum number of server processes which are kept spare
# MaxSpareServers: maximum number of server processes which are kept spare
# MaxClients: maximum number of server processes allowed to start
# MaxRequestsPerChild: maximum number of requests a server process serves
<IfModule mpm_prefork_module>
    ServerLimit           16       //������������õĽ��̵�������ޡ���ֵ��prefok MPM�е�Ӳ������200000����worker��event MPM��Ӳ������20000.�޸ĸ�ֵʱ��ʹ��restart������Ч������MaxClients������Ч��
    StartServers          5        //�ڷ�������ʱ�������ӽ�������
    MinSpareServers       5        //��С���н����������н�����ָû�д�������Ľ��̡�������еĽ�����С�ڸ�ֵʱ�������̾ͻ�������·��������ӽ��̡���һ���Ӳ���һ�����ȴ�һ�룬Ȼ����һ���Ӳ����������ȴ�һ�룬Ȼ����һ���Ӳ����ĸ����ȴ�һ�룬ֱ��һ���Ӳ���32.
    MaxSpareServers      10        //�����н����������н�����ָû�д�������Ľ��̡�������еĽ��������ڸ�ֵ���򸸽��̻�kill������Ľ��̡������ֵС�ڻ����MinSpareServers����Apache���Զ��ĵ�����ֵΪMinSpareServers+1.
    MaxClients          150        //ָ��Apache����ͬʱ���������������ͬʱ��������������ڸ�ֵʱ����������ӽ����Ŷӣ�ֱ��ĳ��������������Ŷӵ����������ԴﵽListenBackLog�趨��ֵ��LiostenBackLogĬ��ֵΪ511����ֵָ�������δ��������ӵĶ��г��ȡ�MaxCientsĬ��ֵΪ256�����Ҫ�������ֵ��Ҳ��Ҫ����ServerLimit��
    MaxRequestsPerChild   0        //ÿ���ӽ��̴�����ٸ�����󽫻��˳���ÿ���ӽ����ڴ����ˡ�MaxRequestsPerChild����������Զ����١�0��ζ�����ޣ����ӽ����������١���Ȼ��Ϊ0����ʹÿ���ӽ��̴����������󣬵������ɷ���ֵҲ��������Ҫ�ĺô����ɷ�ֹ������ڴ�й©���ڷ����������½���ʱ����Զ������ӽ���������ˣ��ɸ��ݷ������ĸ������������ֵ����������KleepAiveʱ��ֻ�е�һ������ᱻ�����������KeepAlive�У���ֵ����˼�ǣ�һ���ӽ��̴�����ٸ����Ӻ󽫻��˳���
</IfModule>

```

* prefork��������

>��httpd��������֮�󣬳�ʼ����5���������̣���StartServers���壩��httpd������Ҫ�Զ������������̵ĸ����������������250���������̣���MaxClients���壩��Ҳ����˵����վ���������ʱ�������˴����������̣����ڷ���������ʱ��������Ҫ��Щ���������ˣ�httpdͨ��MinSpareServers��MaxSpareServers�Զ����ڹ������̵������������ǰ�Ŀ��н��̴���MaxSpareServer����������н�������httpd����ɱ������Ĺ������̣������ǰ�Ŀ��н���С��MinSpareServer�������С���н�������httpd���������µĹ������̣�����1�����̣��Ե�һ���������2�����̣��Ե�һ���������4�����̣�Ȼ��һֱ��ָ����ʽ�������̣�һֱ��ÿ���Ӳ���32���������̣�����ֹͣ�������̣�һֱ����ǰ������������С���н��̣�MinSpareServers)��һ�����������ڴ����������������MaxRequestPerChild)֮�󣬽��ᱻɱ��������Ϊ0��ʾ�������ڡ�


## worker
>worker MPM�����˻�϶���̺Ͷ��̵߳ķ�ʽ��ʹ���̴߳����û�����

```
# worker MPM
# StartServers: initial number of server processes to start
# MaxClients: maximum number of simultaneous client connections
# MinSpareThreads: minimum number of worker threads which are kept spare
# MaxSpareThreads: maximum number of worker threads which are kept spare
# ThreadsPerChild: constant number of worker threads in each server process
# MaxRequestsPerChild: maximum number of requests a server process serves
<IfModule mpm_worker_module>
    ServerLimit          16    //����������Ŀ����õĽ��̵�������ޡ�Ĭ��Ϊ16. worker MPMӲ������20000�����MaxClients����ThreadsPerChild����16ʱ����Ҫ�޸ĸ�ֵ��
    StartServers         3     //��������ʱ��Ĭ�������Ĺ���������
    MaxClients          400    //���������ٸ��ͻ���ͬʱ���ӡ���ֵ��ServerLimit����ThreadsPerChild,������Ҫ���Ӹ�ֵ������Ҫͬʱ����ServerLimit��
    MinSpareThreads      25    //��С�����߳���
    MaxSpareThreads      75    //�������߳���
    ThreadsPerChild      25    //ÿ���������̿��Բ������߳���
    MaxRequestsPerChild   0    //ÿ���������������������������������������ÿ���ӽ����ڴ����ˡ�MaxRequestsPerChild����������Զ����١�0��ζ�����ޣ����ӽ����������١���Ȼ��Ϊ0����ʹÿ���ӽ��̴����������󣬵������ɷ���ֵҲ��������Ҫ�ĺô����ɷ�ֹ������ڴ�й©���ڷ����������½���ʱ����Զ������ӽ���������ˣ��ɸ��ݷ������ĸ������������ֵ����������KleepAiveʱ��ֻ�е�һ������ᱻ�����������KeepAlive�У���ֵ����˼�ǣ�һ���ӽ��̴�����ٸ����Ӻ󽫻��˳���
	Threadlimit  64    //ָ��һ�����̲����̵߳Ŀ����õ�������ޡ�Ĭ��Ϊ64.Ӳ����Ϊ20000.
</IfModule>
```

## event
>һ���̴߳��������󣬻���worker MPM�����ú�workerһ�¡����Ҫʹ��event MPM�����ڱ���ʱ��Ҫʹ��--with-mpm=event��



# ApacheԴ�밲װ�����ű�


# apachectl��httpd��ʹ��

```
[root@vm3 bin]# ./apachectl -h
Usage: /usr/local/source/apache22/bin/httpd [-D name] [-d directory] [-f file]
                                            [-C "directive"] [-c "directive"]
                                            [-k start|restart|graceful|graceful-stop|stop]
                                            [-v] [-V] [-h] [-l] [-L] [-t] [-T] [-S]
Options:
  -D name            : define a name for use in <IfDefine name> directives
  -d directory       : specify an alternate initial ServerRoot
  -f file            : specify an alternate ServerConfigFile
  -C "directive"     : process directive before reading config files
  -c "directive"     : process directive after reading config files
  -e level           : show startup errors of level (see LogLevel)
  -E file            : log startup errors to file
  -v                 : show version number
  -V                 : show compile settings
  -h                 : list available command line options (this page)
  -l                 : list compiled in modules
  -L                 : list available configuration directives
  -t -D DUMP_VHOSTS  : show parsed settings (currently only vhost settings)
  -S                 : a synonym for -t -D DUMP_VHOSTS
  -t -D DUMP_MODULES : show all loaded modules 
  -M                 : a synonym for -t -D DUMP_MODULES
  -t                 : run syntax check for config files
  -T                 : start without DocumentRoot(s) check
[root@vm3 bin]# 

˵����
-D��ָ��һ��������<IfDefine name>ָ���е�name��
-d��ָ��ServerRoot��Ŀ¼��
-f��ָ�����������ļ���
-C���ڶ�ȡ�����ļ�֮ǰ����ָ�
-c���ڶ�ȡ�����ļ�֮����ָ�
-v����ʾ�汾�š�
-V����ʾ�������á�
-h���г����õ�������ѡ�
-l���г������ģ�顣
-L���г����õ�����ָ�
-t -D DUMP_VHOSTS��������������������
-S��������������������
-t -D DUMP_MODULES����ʾ���������ģ�顣
-M����ʾ���������ģ�顣
-t�������﷨��顣
-T���������񣬲�����DocumentRoot�ļ�顣
-k start|stop|restart|graceful|graceful-stop����ͣ���������

```

## �ź�˵��
* stop
>apachectl -k stop��httpd -k stop�����͵���SIGTERM(kill -15)�źš���֪ͨ������(httpd.pid�ļ�����Ľ��̺�)����kill�����е��ӽ��̣������е��ӽ��̽����󣬸�����Ҳ���˳�������ֹ���е�����(�������ڴ����)�����Ҳ�������µ�����


* restart
>apachectl -k restart��httpd -k restart�����͵���SIGHUP(kill -1)�źš���֪ͨ��������ֹ���е��ӽ��̣��������̲����˳���Ȼ�󸸽��̻����¶�ȡ�����ļ���Ȼ�����´���־�ļ�����󸸽��̻�spawns(fork and exec)һ���µ��ӽ��̴���ͻ��˵�����

* graceful
>apachectl -k graceful��httpd -k graceful����ʾ�������ŵ����������͵���SIGUSR1(kill -10)�źŸ������̡����źŻ�֪ͨ�ӽ��̴����굱ǰ���ڴ����������˳�(����ӽ��̵�ǰû�д����κ������������˳�)��Ȼ�󸸽��̻����¶�ȡ�����ļ������´���־�ļ����������µ��ӽ�������Ѿ��˳����ӽ��̴����µ�����
ע�⣺��������ļ��д����������httpdֹͣ����

* graceful-stop
>apachectl -k graceful-stop��httpd -k graceful-stop����ʾ�������ŵ�ֹͣ�����͵���SIGWINCH(kill -28)�źŸ������̡����źŻ�֪ͨ�ӽ��̴����굱ǰ���ڴ����������˳�(����ӽ��̵�ǰû�д����κ������������˳�)��Ȼ�󸸽��̽���ɾ��PID�ļ�����ֹͣ�������κζ˿��ϡ������̽���������У����Ҽ������ڴ���������ӽ��̣������е��ӽ��̴������������˳�������ǳ���GracefulShutdownTimeout��ָ����ʱ�䣬�����̽����˳��������ʱ����ʣ�µ��ӽ��̻��յ�SIGTERM�źţ�ǿ���˳���


# �ڲ����±���Apache�������֧������ģ��
```
1�����Ƚ��뵽Apache��Դ�����modulesĿ¼�¡�
[root@vm02 modules]# pwd
/opt/httpd-2.2.31/modules
[root@vm02 modules]# 

2�����뵽��Ҫ��װ��ģ��Ŀ¼
[root@vm02 modules]# cd proxy/
[root@vm02 proxy]# 

3����װģ��
[root@vm02 proxy]# /usr/local/source/apache22/bin/apxs -i -a -c mod_proxy.c 
˵����
-i����ʾ��װģ�顣
-a����ʾ����ģ�顣
-A����ʾע��ģ�顣
-c����ѡ���ʾ��Ҫִ�б�������������Ȼ����CԴ����(.c)filesΪ��Ӧ��Ŀ������ļ�(.o)��Ȼ��������ЩĿ������files�������Ŀ������ļ�(.o��.a)�������ɶ�̬�������dso file �����û��ָ�� -o ѡ��������ļ�����files�еĵ�һ���ļ����Ʋ�õ���Ҳ����Ĭ��Ϊmod_name.so

```