# 安装requests模块
```
[root@vm11 ~]# pip2.7 install requests
```

# requests模块的使用

login_url = 'http://172.28.4.2/screens/frameset.html'
macfilter_url = 'http://172.28.4.2/screens/aaa/macfilter_create.html'

POST

access_control=1&csrf_token=&macaddr=00%3A00%3A00%3A00%3A00%3A01&WirelessWlanID=2&description=felix+test&ipaddr=&macFilterInterface=0&err_flag=&err_msg=&info_flag=&info_msg=&buttonClicked=4

dict(access_control=1, csrf_token='', macaddr='00:00:00:00:00:01', WirelessWlanID=2, description='felix.test', ipaddr='', macFilterInterface=0, err_flag='', err_msg='', info_flag='', info_msg='', buttonClicked=4)


