[TOC]
[Google Authenticator](https://github.com/google/google-authenticator)
# CentOSϵͳ
## ����google authenticator
```
git clone https://github.com/google/google-authenticator.git
```
## ���밲װgoogle authenticator
```
��װautoconf��automake��pam-devel
[root@control libpam]# yum install -y autoconf
[root@control libpam]# yum install -y automake
[root@control libpam]# yum install -y pam-devel


��װgoogle authenticator
[root@bjcorppan01 ~]# cd google-authenticator/
[root@bjcorppan01 google-authenticator]# cd libpam/
[root@bjcorppan01 libpam]# ./bootstrap.sh
[root@bjcorppan01 libpam]# ./configure
[root@bjcorppan01 libpam]# make
[root@bjcorppan01 libpam]# make install

���ļ�Ĭ�ϰ�װ�ڣ�/usr/local/lib/securityĿ¼��
[root@bjcorppan01 libpam]# ls -l /usr/local/lib/security/
������ 104
-rwxr-xr-x 1 root root   1024 4��  15 15:05 pam_google_authenticator.la
-rwxr-xr-x 1 root root 100532 4��  15 15:05 pam_google_authenticator.so
[root@bjcorppan01 libpam]#
```

## ����SSH����google authenticator
```
* �༭PAM��SSHD�����ļ���/etc/pam.d/sshd
��һ����ӣ�auth	required	/usr/local/lib/security/pam_google_authenticator.so no_increment_hotp

* �޸�sshd_conf�����ļ�
ʹ����������;
ChallengeResponseAuthentication yes
UsePAM yes

* ����sshd����
[root@bjcorppan01 libpam]# /etc/init.d/sshd restart
ֹͣ sshd��                                                [ȷ��]
�������� sshd��                                            [ȷ��]
[root@bjcorppan01 libpam]#

* ���û��ļ�Ŀ¼������secret key
���google-authenticator
���ô洢λ�ã�~/.google_authenticator

#����google-authenticator�����Ƴ���ֻ��Ҫ����һ��
[root@bjcorppan01 ~]# google-authenticator

#�Ƿ�ʹ�û���ʱ�����֤
Do you want authentication tokens to be time-based (y/n) y
#�������Ϊ���ɵĶ�ά�����ӣ���Ҫ�ֻ�����google authenticator�������ɨ�����Ӳ����Ķ�ά��
https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/root@bjcorppan01%3Fsecret%3DMAIGMXNWS2GJMWGM%26issuer%3Dbjcorppan01
Your new secret key is: MAIGMXNWS2GJMWGM
Your verification code is 259369
#������֤��
Your emergency scratch codes are:
  62291274
  15169081
  49556685
  99169134
  58327759

#�Ƿ�������.google_authenticator�ļ�
Do you want me to update your "/root/.google_authenticator" file (y/n) y

#��ֹһ�����������;
Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y

# �Ƿ���ʱ���ݴ���ֹ�ͻ��˺ͷ�����ʱ�����̫Զ������֤ʧ�ܡ�
By default, tokens are good for 30 seconds and in order to compensate for
possible time-skew between the client and the server, we allow an extra
token before and after the current time. If you experience problems with poor
time synchronization, you can increase the window from its default
size of 1:30min to about 4min. Do you want to do so (y/n) y

#�Ƿ�򿪳��Դ������ƣ���ֹ�����ƽ�
If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting (y/n) y
[root@bjcorppan01 ~]#
```
## ����
```
Felix-MacBook:~ felix$ ssh root@pan.kakaocorp.cn
Verification code:
Password:
Last login: Fri Apr 15 15:53:03 2016 from 59.108.67.178

Welcome to aliyun Elastic Compute Service!

[root@bjcorppan01 ~]#
```

# Ubuntuϵͳ
## ��װ������
```
sudo apt-get install libpam0g-dev libqrencode3
```

## ���밲װ����
�ο�CentOS
