#!/bin/bash
if [ "$UID" != "0" ];then
    echo "please execute this scripte using sudo"
    exec sudo $0
    exit 0 
else
    echo "pass"
fi
##
# 1. setup root privilege
##
echo -e '111111\n111111' | passwd root

# make new account
echo "input the account you would like to make: default(blockchain)"
if [ "${1}" != "" ]; then
    newuser=$1
else
    newuser="blockchain"
fi
isUser=`id $newuser`
if [ ${#isUser} ]; then
    echo "$newuser is already exist"
    sudo adduser $newuser sudo
    echo -e '111111\n111111'| sudo -S passwd $newuser
else
    sudo useradd -m $newuser -s /bin/bash -G sudo adm
    echo -e '111111\n111111'| sudo -S passwd $newuser
    echo "$newuser is created now"
fi


##
# 2. repository update and upgrade
##
sudo apt-get update -y && sudo apt-get upgrade -y

##
# 3. install packages
##
sudo apt-get install -y build-essential
sudo apt-get install -y git curl
sudo apt-get install -y openssh-server openssh-client sshpass

##
# 4. Download go
##
## check go path installed
if [ -e /usr/local/go ]; then
    # pass
    echo pass
else
    cd ~ 
    curl -O https://dl.google.com/go/go1.9.7.linux-amd64.tar.gz

    # Decompress go.tar.gz
    tar -zxvf go1.9.7.linux-amd64.tar.gz

    # Move go folder to /usr/local
    sudo mv go /usr/local
fi

# Add go excutable file to PATH
sudo echo 'GOPATH="/usr/local/go"' > /etc/profile.d/go_env.sh
sudo echo 'PATH="$PATH:$GOPATH/bin"' >> /etc/profile.d/go_env.sh
source /etc/profile.d/go_env.sh

##
# 5. install go-ethereum
##
## check go-ethereum path installed
cgeth=`which geth`
if [ ${#cgeth} ]; then
    # pass
    echo pass
else
    # Clone go-ethereum
    cd ~
    git clone http://github.com/ethereum/go-ethereum

    # Move go-ethereum folder to local user and provide user own privileges
    sudo mv go-ethereum /home/$newuser/
    sudo chown -R $newuser.$newuser /home/$newuser/go-ethereum


    # Build go-ethereum
    cd /home/$newuser/go-ethereum
    make geth && mv /home/$newuser/go-ethereum/build/bin/geth /usr/bin 
fi

##
# 6. deploy public key
##

# generate dual keys
rm -rf ~/.ssh
mkdir ~/.ssh
ssh-keygen -N "" -f ~/.ssh/id_rsa
