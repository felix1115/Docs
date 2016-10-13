# 会话加密通信过程
![会话加密通信过程](https://github.com/felix1115/Docs/blob/master/Images/openssl-1.png)

```
1、Bob生成数据
2、用单向加密数据生成特征码
3、Bob用自己的私钥加密特征码放在数据后面———用自己的私钥进行签名；
4、生成临时会话密钥加密特征码和数据——因为之前没有对数据进行加密；
5、用对方Alice的公钥加密临时密钥
6、数据加密完后一并发给对方
7、Alice用自己的私钥解密对称密钥（原图有误不是BOb）
8、拿到密码后解密对方加密的数据
9、Alice用Bob的公钥解密特征码—————使用发送者的公钥对签名进行认证；
10、Alice用相同的单向加密验证数据的完整性
11、Alice接收数据
```

# 自建CA
* /etc/pki/CA目录结构
```
[root@vm1 ~]# tree /etc/pki/CA/
/etc/pki/CA/
├── certs
├── crl
├── newcerts
└── private

4 directories, 0 files
[root@vm1 ~]# 

说明：
certs：CA签发的证书存放位置。
crl：CA吊销的证书存放的位置。
newcerts：CA签发的新的证书存放位置。
serial：签发证书时需要用到的序列号。需要手动创建，并指定初始序列号。
index.txt：数据库的索引文件。需要手动创建并指定初始值。
crlnumber：吊销证书时需要用到的序列号。需要手动创建。
```

* 创建serial和index.txt
```
[root@vm1 ~]# echo 01 > /etc/pki/CA/serial
[root@vm1 ~]# touch /etc/pki/CA/index.txt
[root@vm1 ~]# 
```

* 创建CA私钥(默认为cakey.pem)
```
[root@vm1 ~]# (umask 077; openssl genrsa -out /etc/pki/CA/private/cakey.pem 2048)
Generating RSA private key, 2048 bit long modulus
.................+++
.......+++
e is 65537 (0x10001)
[root@vm1 ~]# 
```

* 生成自签名的证书
```
说明：证书名默认是cacert.pem

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


选项说明：
-new：生成新的证书。
-x509：通常用于自签名证书。
-key：私钥位置。
-out：生成证书的位置。
-days：申请的天数。默认为30天。

```

# 签发服务器证书
* 服务器生成私钥
```
[root@vm3 apache22]# (umask 077; openssl genrsa -out ssl/apache22-keys.pem 2048)
Generating RSA private key, 2048 bit long modulus
.........................................................+++
......+++
e is 65537 (0x10001)
[root@vm3 apache22]# 
```

* 服务器生成CSR
```
1. 生成SHA1的证书签名请求(SHA1是160bit长度)
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

注：challenge password直接回车。


2. 生成SHA2的证书签名请求(SHA2包括SHA256、SHA384、SHA512)
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


3. 查看签出的CSR是SHA1还是SHA2
[root@vm3 apache22]# openssl req -in ssl/apache22-felix_com.csr -noout -text | grep Signature
    Signature Algorithm: sha1WithRSAEncryption
[root@vm3 apache22]# 

[root@vm3 apache22]# openssl req -in ssl/sha256-apache22-felix_com.csr -noout -text | grep Signature
    Signature Algorithm: sha256WithRSAEncryption
[root@vm3 apache22]#

```

* 服务器端的CSR发送到CA
```
[root@vm3 apache22]# scp ssl/apache22-felix_com.csr root@172.17.100.1:/etc/pki/CA/csr/
Password: 
apache22-felix_com.csr                                                                                                                                     100% 1050     1.0KB/s   00:00    
[root@vm3 apache22]# 

```

* CA签发证书
```
命令：openssl ca -in csr/apache22-felix_com.csr -out apache22-https.crt

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

* 将证书传到服务器端
```
[root@vm01 CA]# scp apache22-https.crt root@172.17.100.3:/usr/local/source/apache22/ssl/
Enter passphrase for key '/root/.ssh/id_rsa': 
root@172.17.100.3's password: 
apache22-https.crt                                                                                                                                         100% 4604     4.5KB/s   00:00    
[root@vm01 CA]# 
```