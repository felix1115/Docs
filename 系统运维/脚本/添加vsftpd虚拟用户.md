# 说明
```
1. 用户采用vsftp的虚拟用户
2. 虚拟用户的名称和组是vuser和vuser
3. 每一个用户一个数据目录
```


# 代码
```
#!/bin/bash
# add ftp user

prefix='/etc/vsftpd'
priv_file="$prefix/user_list"
user_file="$prefix/vusers"
user_db="$prefix/vuserdb.db"
user_dir="$prefix/users"
data_dir="/data/ftp"
vusername='vuser'
vgroupname='vuser'

add=0

help() {
    echo
    echo "$0 username password [username password] ..."
    echo
}

check_user() {
    username=$1
    is_exist=$(awk 'NR%2' $user_file | grep $username)
    if [ -z "$is_exist" ]; then
        # 1 means the user is not exist
        return 1
    else
        # 0 means the user is exist
        return 0
    fi
}


add_user() {
    username=$1
    password=$2

    # add username and password
    echo "$username" >> $user_file
    echo "$password" >> $user_file
    db_load -T -t hash -f $user_file $user_db

    # add privileges
    echo "$username" >> $priv_file

    # create user privileges
    echo "local_root=$data_dir/$username" >> $user_dir/$username
    mkdir $data_dir/$username
    chown $vusername:$vgroupname $data_dir/$username
}

if [ $(id -u) -ne 0 ]; then
    echo
    echo "Your are not allowed, please use root account!"
    echo "Quit"
    exit 0
fi


if [ $(($#%2)) -ne 0 ] || [ $# -lt 2 ]; then
    help
    exit 0
fi

users=$(echo $@ | awk '{for(i=1; i<=NF; i+=2) print $i}')
passwords=$(echo $@ | awk '{for(i=2; i<=NF; i+=2) print $i}')

while [ $# != 0 ]
do
    check_user $1
    retval=$?
    if [ $retval -eq 0 ]; then
        echo "$1 is exist, skip the user"
        shift 2
        continue
    else
        add_user $1 $2
        echo "Add user $1, Password: $2"
        add=1
        shift 2
    fi
done

if [ $add -eq 1 ]; then
    echo
    echo "Reload vsftpd"
    /etc/init.d/vsftpd reload &> /dev/null
fi
