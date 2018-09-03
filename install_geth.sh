#!/bin/bash

# Prerequisite
sudo apt-get install sshpass -y

# common user id
loginuser=block

lines=`cat iplist.txt | wc -l`
if [ $lines = 0 ]; then
    echo "need to add both ip address and hostname to iplist.txt"
    exit 0
fi
# Remote service
for ((ip=1; ip<=lines; ip++)); do
    line=`sed -n ${ip}p iplist.txt`
    if echo "$line" | grep -q "#"; then
        echo comment line: ${line}
        continue
    fi
    ipaddr=`echo $line | awk '{print $1}'`   
    hostaddr=`echo $line | awk '{print $2}'`   

    hostslinenum=`sed -n "/# The following.*/=" /etc/hosts`
    if cat /etc/hosts | grep -q "${ipaddr}"; then
        echo "${ipaddr} is in /etc/hosts"
    else
        sudo sed -i "$((hostslinenum - 1))i ${line}" /etc/hosts
    fi
       

    sshpass -p "111111" ssh -o StrictHostKeyChecking=no $loginuser@$hostaddr "\
    echo -e \"111111\n\" | sudo -S sed -i.bak \"s/prohibit-password/yes/g\" /etc/ssh/sshd_config;\
    echo -e \"111111\n\" | sudo -S service ssh restart;\
    echo -e \"111111\n111111\n111111\" | sudo -S passwd root;\
    " 1&> /dev/null
    echo -ne 'progress: ##                (10%)\r'
    sleep 1
    sshpass -p "111111" ssh -o StrictHostKeyChecking=no root@$hostaddr "hostnamectl set-hostname $hostaddr" 1> /dev/null 
    echo -ne 'progress: ####              (20%)\r'
    sleep 1
    sshpass -p "111111" scp -o StrictHostKeyChecking=no set_config.sh root@$hostaddr:/root/ 1> /dev/null
    echo -ne 'progress: ########          (40%)\r'
    sleep 1
    sshpass -p "111111" ssh -o StrictHostKeyChecking=no root@$hostaddr "nohup sudo /root/set_config.sh" 1> /dev/null 
    echo -ne 'progress: #############     (70%)\r'
    sleep 1
    sshpass -p "111111" ssh-copy-id -o StrictHostKeyChecking=no $hostaddr 1> /dev/null
    echo -ne 'progress: ##################(100%)\r\n'
    sleep 1
done
