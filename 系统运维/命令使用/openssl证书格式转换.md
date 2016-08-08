# 证书格式介绍
```text
PEM格式通常用于数字证书认证机构（Certificate Authorities，CA），扩展名为.pem, .crt, .cer, and .key。内容为Base64编码的ASCII码文件，有类似"-----BEGIN CERTIFICATE-----" 和 "-----END CERTIFICATE-----"的头尾标记。服务器认证证书，中级认证证书和私钥都可以储存为PEM格式（认证证书其实就是公钥）。Apache和类似的服务器使用PEM格式证书。

DER 格式
DER格式与PEM不同之处在于其使用二进制而不是Base64编码的ASCII。扩展名为.der，但也经常使用.cer用作扩展名，所有类型的认证证书和私钥都可以存储为DER格式。Java使其典型使用平台。

PKCS#7/P7B 格式
PKCS#7 或 P7B格式通常以Base64的格式存储，扩展名为.p7b 或 .p7c，有类似BEGIN PKCS7-----" 和 "-----END PKCS7-----"的头尾标记。PKCS#7 或 P7B只能存储认证证书或证书路径中的证书（就是存储认证证书链，本级，上级，到根级都存到一个文件中）。不能存储私钥，Windows和Tomcat都支持这种格式。

PKCS#12/PFX 格式
PKCS#12 或 PFX格式是以加密的二进制形式存储服务器认证证书，中级认证证书和私钥。扩展名为.pfx 和 .p12，PFX通常用于Windows中导入导出认证证书和私钥。
```

# 私钥格式介绍
```text
PKCS8格式的私钥：
-----BEGIN PRIVATE KEY-----

-----END PRIVATE KEY-----


RSA格式的私钥：
-----BEGIN RSA PRIVATE KEY-----

-----END RSA PRIVATE KEY-----

```


# 转换PEM证书
## PEM to DER
```bash
# openssl x509 -outform der -in certificate.pem -out certificate.der
```

## PEM to P7B
```bash
# openssl crl2pkcs7 -nocrl -certfile certificate.cer -out certificate.p7b -certfile CACert.cer
```

## PEM to PFX(pkcs12)
```bash
# openssl pkcs12 -export -out certificate.pfx -inkey privateKey.key -in certificate.crt -certfile CACert.crt
```


# 转换P7B证书
## P7B to PEM
```bash
# openssl pkcs7 -print_certs -in certificate.p7b -out certificate.cer
```

## P7B to PFX
```bash
# 先转换成PEM格式
# openssl pkcs7 -print_certs -in certificate.p7b -out certificate.cer
# 将PEM格式的证书转换为PFX
# openssl pkcs12 -export -out certificate.pfx -inkey privateKey.key -in certificate.crt -certfile CACert.crt
```

# 转换PFX证书
## PFX to PEM
```bash
# openssl pkcs12 -in certificate.pfx -out certificate.cer -nodes
# 注意：PFX转换PEM后的证书文件中包含服务器证书、CA证书以及私钥，需要把他们分开才能使用。产生的私钥默认是PKCS8格式的。和RSA私钥格式不同。

# 产生ca证书
# openssl pkcs12 -in client_ssl.pfx -out root.pem -cacerts
# 产生服务器证书
# openssl pkcs12 -in client_ssl.pfx -out client_ssl.pem -clcerts
# PKCS8私钥转换成RSA私钥
#  openssl rsa -in pkcs8.key -out rsa.key
```

# 转换DER证书
```bash
# openssl x509 -infrom der -in certficate.cer -out certificate.pem
```
