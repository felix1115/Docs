[SSL证书检测网站](https://csr.chinassl.net/ssl-checker.html)

# 检测SSL证书到期时间
```
#!/bin/bash

server=$1
openssl=/usr/bin/openssl

cert_file="$PWD/$1.crt"

echo "Getting certificate from $server ..."
$openssl s_client -host $1 -port 443 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $cert_file

if [ -s $cert_file ]; then
    echo "--------------------- Result -------------------"
    enddate=$($openssl x509 -noout -in $cert_file -enddate | awk -F'=' '{print $2}')
    echo "$1: $enddate"
    echo "---------------------- End ---------------------"
else
    echo
    echo "Get certificate from $server failed"
    echo
fi
```

# 使用方法
```
➜  Desktop /bin/bash checkCertEndDate.sh www.baidu.com
Getting certificate from www.baidu.com ...
--------------------- Result -------------------
www.baidu.com: Aug 16 23:59:59 2017 GMT
--------------------- End -------------------
➜  Desktop
```