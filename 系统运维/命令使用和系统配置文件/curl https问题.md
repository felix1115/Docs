# curl https问题解决方法
```
原因：使用curl命令访问https网站时，默认情况下，curl会执行SSL证书验证，在Linux系统下，授信的CA的公钥存放在/etc/pki/tls/certs/ca-bundle.crt中。
```

## 方法1：使用-k或者是--insecure选项
```bash
# curl -k https://www.felix.com
```

## 方法2：使用--cacert选项，指定ca证书文件
```bash
# curl --cacert zhongjica.cert https://www.felix.com
```

## 方法3：将CA证书文件添加到ca-bundle.crt文件中
```bash
# dos2unix zhongjica.cert
# cat zhongjica.cert >> /etc/pki/tls/certs/ca-bundle.crt
```