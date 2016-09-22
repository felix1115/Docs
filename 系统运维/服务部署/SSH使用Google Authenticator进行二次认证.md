[TOC]
[Google Authenticator](https://github.com/google/google-authenticator)
# CentOS系统
## 下载google authenticator
```
git clone https://github.com/google/google-authenticator.git
```
## 编译安装google authenticator
```
安装autoconf和automake、pam-devel
[root@control libpam]# yum install -y autoconf
[root@control libpam]# yum install -y automake
[root@control libpam]# yum install -y pam-devel


安装google authenticator
[root@bjcorppan01 ~]# cd google-authenticator/
[root@bjcorppan01 google-authenticator]# cd libpam/
[root@bjcorppan01 libpam]# ./bootstrap.sh
[root@bjcorppan01 libpam]# ./configure
[root@bjcorppan01 libpam]# make
[root@bjcorppan01 libpam]# make install

库文件默认安装在：/usr/local/lib/security目录下
[root@bjcorppan01 libpam]# ls -l /usr/local/lib/security/
总用量 104
-rwxr-xr-x 1 root root   1024 4月  15 15:05 pam_google_authenticator.la
-rwxr-xr-x 1 root root 100532 4月  15 15:05 pam_google_authenticator.so
[root@bjcorppan01 libpam]#
```

## 配置SSH调用google authenticator
```
* 编辑PAM的SSHD配置文件：/etc/pam.d/sshd
第一行添加：auth	required	/usr/local/lib/security/pam_google_authenticator.so no_increment_hotp

* 修改sshd_conf配置文件
使用如下内容;
ChallengeResponseAuthentication yes
UsePAM yes

* 重启sshd服务
[root@bjcorppan01 libpam]# /etc/init.d/sshd restart
停止 sshd：                                                [确定]
正在启动 sshd：                                            [确定]
[root@bjcorppan01 libpam]#

* 在用户的家目录下生成secret key
命令：google-authenticator
配置存储位置：~/.google_authenticator

#运行google-authenticator二进制程序，只需要运行一次
[root@bjcorppan01 ~]# google-authenticator

#是否使用基于时间的认证
Do you want authentication tokens to be time-based (y/n) y
#这个链接为生成的二维码链接，需要手机下载google authenticator软件，并扫描链接产生的二维码
https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/root@bjcorppan01%3Fsecret%3DMAIGMXNWS2GJMWGM%26issuer%3Dbjcorppan01
Your new secret key is: MAIGMXNWS2GJMWGM
Your verification code is 259369
#紧急验证码
Your emergency scratch codes are:
  62291274
  15169081
  49556685
  99169134
  58327759

#是否更新你的.google_authenticator文件
Do you want me to update your "/root/.google_authenticator" file (y/n) y

#禁止一个口令多种用途
Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y

# 是否开启时间容错，防止客户端和服务器时间相差太远导致认证失败。
By default, tokens are good for 30 seconds and in order to compensate for
possible time-skew between the client and the server, we allow an extra
token before and after the current time. If you experience problems with poor
time synchronization, you can increase the window from its default
size of 1:30min to about 4min. Do you want to do so (y/n) y

#是否打开尝试次数限制，防止暴力破解
If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting (y/n) y
[root@bjcorppan01 ~]#
```
## 测试
```
Felix-MacBook:~ felix$ ssh root@pan.kakaocorp.cn
Verification code:
Password:
Last login: Fri Apr 15 15:53:03 2016 from 59.108.67.178

Welcome to aliyun Elastic Compute Service!

[root@bjcorppan01 ~]#
```

# Ubuntu系统
## 安装依赖包
```
sudo apt-get install libpam0g-dev libqrencode3
```

## 编译安装配置
参考CentOS
