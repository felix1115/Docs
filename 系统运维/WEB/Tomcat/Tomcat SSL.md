# 步骤1:将PEM格式的私钥和中级CA转换为PKCS12证书格式

```bash
# 这一步需要设置一个密码
# openssl pkcs12 -export -out changeme.pfx -inkey privateKey_changeme.key -in serverCert_changeme.crt -certfile CACert_changeme.crt
```

# 步骤2:生成keystore文件
```bash
# 注意：这里使用destalias定义的名字为私钥别名，在步骤4导入服务器证书时需要使用。
# keytool -importkeystore -deststorepass changeme -destkeypass changeme -destkeystore changeme.jks -destalias changeme -srckeystore changeme.pfx -srcstoretype PKCS12 -srcstorepass changeme -srcalias 1
```

# 步骤3：导入中级CA(有几张导入几张)
```bash
# keytool -import -alias ca1 -keystore changeme.jks -trustcacerts -storepass changeme -file CACert.crt -noprompt

# keytool -import -alias ca2 -keystore changeme.jks -trustcacerts -storepass changeme -file CACert.crt -noprompt
```

# 步骤4：导入服务器证书
```bash
# 注意：这里的alias为服务器证书别名，必须和步骤2生成的keystory的私钥别名一致。
# keytool -import -alias changeme -keystore changeme.jks -trustcacerts -storepass changeme -keypass changeme -file serverCert_changeme.crt
```

# 步骤5：查看keystore文件内容
```bash
# keytool -list -keystore changeme.jks -storepass changeme
```

# 步骤6：配置Tomcat
```bash
复制changeme.jks文件到Tomcat安装目录下的conf目录。打开conf目录下的server.xml文件，找到并修改以下内容
    <!--
    <Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
               maxThreads="150" scheme="https" secure="true"
               clientAuth="false" sslProtocol="TLS" />
SSL访问端口
    -->
修改为
    <Connector port="443" protocol="org.apache.coyote.http11.Http11Protocol" SSLEnabled="true"
               maxThreads="150" scheme="https" secure="true"
               keystoreFile="conf\changeme.jks" keystorePass="password"
               clientAuth="false" sslProtocol="TLS"
 ciphers="TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256"  />
```

# 步骤7：证书备份和恢复
```bash
# 证书备份的时候，只需要备份changeme.jks文件即可。恢复的时候，只需要将changme.jks复制到指定的位置即可。
```
