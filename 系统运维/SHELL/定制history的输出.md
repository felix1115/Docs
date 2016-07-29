# 定制history命令的输出
```bash
[root@vm10 ~]# cat /etc/profile.d/history-format.sh
HISTTIMEFORMAT="Time:%F %T User:$(whoami) IP:$(echo $SSH_CLIENT | awk '{print $1}') Command: "
[root@vm10 ~]#
```
