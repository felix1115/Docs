# �Ự����ͨ�Ź���
![�Ự����ͨ�Ź���](https://github.com/felix1115/Docs/blob/master/Images/openssl-1.png)

```
1��Bob��������
2���õ��������������������
3��Bob���Լ���˽Կ����������������ݺ��桪�������Լ���˽Կ����ǩ����
4��������ʱ�Ự��Կ��������������ݡ�����Ϊ֮ǰû�ж����ݽ��м��ܣ�
5���öԷ�Alice�Ĺ�Կ������ʱ��Կ
6�����ݼ������һ�������Է�
7��Alice���Լ���˽Կ���ܶԳ���Կ��ԭͼ������BOb��
8���õ��������ܶԷ����ܵ�����
9��Alice��Bob�Ĺ�Կ���������롪��������ʹ�÷����ߵĹ�Կ��ǩ��������֤��
10��Alice����ͬ�ĵ��������֤���ݵ�������
11��Alice��������
```

# �Խ�CA
* /etc/pki/CAĿ¼�ṹ
```
[root@vm1 ~]# tree /etc/pki/CA/
/etc/pki/CA/
������ certs
������ crl
������ newcerts
������ private

4 directories, 0 files
[root@vm1 ~]# 

˵����
certs��CAǩ����֤����λ�á�
crl��CA������֤���ŵ�λ�á�
newcerts��CAǩ�����µ�֤����λ�á�
serial��ǩ��֤��ʱ��Ҫ�õ������кš���Ҫ�ֶ���������ָ����ʼ���кš�
index.txt�����ݿ�������ļ�����Ҫ�ֶ�������ָ����ʼֵ��
crlnumber������֤��ʱ��Ҫ�õ������кš���Ҫ�ֶ�������
```

* ����serial��index.txt
```
[root@vm1 ~]# echo 01 > /etc/pki/CA/serial
[root@vm1 ~]# touch /etc/pki/CA/index.txt
[root@vm1 ~]# 
```

* ����CA˽Կ(Ĭ��Ϊcakey.pem)
```
[root@vm1 ~]# (umask 077; openssl genrsa -out /etc/pki/CA/private/cakey.pem 2048)
Generating RSA private key, 2048 bit long modulus
.................+++
.......+++
e is 65537 (0x10001)
[root@vm1 ~]# 
```

* ������ǩ����֤��
```
˵����֤����Ĭ����cacert.pem

[root@vm1 ~]# openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:BeiJing
Locality Name (eg, city) [Default City]:BeiJing
Organization Name (eg, company) [Default Company Ltd]:felix
Organizational Unit Name (eg, section) []:IT Dept
Common Name (eg, your name or your server's hostname) []:ca.felix.com
Email Address []:admin@felix.com
[root@vm3 ~]# 


ѡ��˵����
-new�������µ�֤�顣
-x509��ͨ��������ǩ��֤�顣
-key��˽Կλ�á�
-out������֤���λ�á�
-days�������������Ĭ��Ϊ30�졣

```

# ǩ��������֤��
* ����������˽Կ
```
[root@vm3 apache22]# (umask 077; openssl genrsa -out ssl/apache22-keys.pem 2048)
Generating RSA private key, 2048 bit long modulus
.........................................................+++
......+++
e is 65537 (0x10001)
[root@vm3 apache22]# 
```

* ����������CSR
```
1. ����SHA1��֤��ǩ������(SHA1��160bit����)
[root@vm3 apache22]# openssl req -new -key ssl/apache22-keys.pem -out ssl/apache22-felix_com.csr -days 365
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:BeiJing
Locality Name (eg, city) [Default City]:BeiJing
Organization Name (eg, company) [Default Company Ltd]:felix
Organizational Unit Name (eg, section) []:IT Dept
Common Name (eg, your name or your server's hostname) []:*.felix.com
Email Address []:admin@felix.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
[root@vm3 apache22]# 

ע��challenge passwordֱ�ӻس���


2. ����SHA2��֤��ǩ������(SHA2����SHA256��SHA384��SHA512)
[root@vm3 apache22]# openssl req -sha256 -new -key ssl/apache22-keys.pem -out ssl/sha256-apache22-felix_com.csr -days 365
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:BeiJing
Locality Name (eg, city) [Default City]:BeiJing
Organization Name (eg, company) [Default Company Ltd]:felix
Organizational Unit Name (eg, section) []:IT Dept
Common Name (eg, your name or your server's hostname) []:*.felix.com
Email Address []:admin@felix.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
[root@vm3 apache22]#


3. �鿴ǩ����CSR��SHA1����SHA2
[root@vm3 apache22]# openssl req -in ssl/apache22-felix_com.csr -noout -text | grep Signature
    Signature Algorithm: sha1WithRSAEncryption
[root@vm3 apache22]# 

[root@vm3 apache22]# openssl req -in ssl/sha256-apache22-felix_com.csr -noout -text | grep Signature
    Signature Algorithm: sha256WithRSAEncryption
[root@vm3 apache22]#

```

* �������˵�CSR���͵�CA
```
[root@vm3 apache22]# scp ssl/apache22-felix_com.csr root@172.17.100.1:/etc/pki/CA/csr/
Password: 
apache22-felix_com.csr                                                                                                                                     100% 1050     1.0KB/s   00:00    
[root@vm3 apache22]# 

```

* CAǩ��֤��
```
���openssl ca -in csr/apache22-felix_com.csr -out apache22-https.crt

[root@vm01 CA]# openssl ca -in csr/apache22-felix_com.csr -out apache22-https.crt
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Oct 13 09:14:38 2016 GMT
            Not After : Oct 13 09:14:38 2017 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = BeiJing
            organizationName          = felix
            organizationalUnitName    = IT Dept
            commonName                = *.felix.com
            emailAddress              = admin@felix.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                DC:FA:EA:5E:1D:82:B6:E1:F1:45:09:60:15:32:DF:25:88:17:FC:4B
            X509v3 Authority Key Identifier: 
                keyid:68:2B:E8:D5:20:9E:20:F9:C7:B2:3D:7F:80:75:53:E6:12:E4:AD:3A

Certificate is to be certified until Oct 13 09:14:38 2017 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
[root@vm01 CA]# 

```

* ��֤�鴫����������
```
[root@vm01 CA]# scp apache22-https.crt root@172.17.100.3:/usr/local/source/apache22/ssl/
Enter passphrase for key '/root/.ssh/id_rsa': 
root@172.17.100.3's password: 
apache22-https.crt                                                                                                                                         100% 4604     4.5KB/s   00:00    
[root@vm01 CA]# 
```