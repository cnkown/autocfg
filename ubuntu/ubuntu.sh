#!/bin/bash

# ������ɫ����
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

# ��Ϣ��ʾ����
Msg_Info="${Font_Blue}[Info] ${Font_Suffix}"
Msg_Warning="${Font_Yellow}[Warning] ${Font_Suffix}"
Msg_Debug="${Font_Yellow}[Debug] ${Font_Suffix}"
Msg_Error="${Font_Red}[Error] ${Font_Suffix}"
Msg_Success="${Font_Green}[Success] ${Font_Suffix}"
Msg_Fail="${Font_Red}[Failed] ${Font_Suffix}"

START_PATH=$(pwd)

reboot_os() {
    echo 0
    echo -e "${Msg_Info}The system needs to reboot."
    read -p "Restart takes effect immediately. Do you want to restart system? [y/n]" is_reboot
    if [[ ${is_reboot} == "y" || ${is_reboot} == "Y" ]]; then
        reboot
    else
        echo -e "${Msg_Info}Reboot has been canceled..."
        exit 0
    fi
}

environment_Install() {
    apt -y install epel-release
    apt -y install net-tools wget curl firewalld
    apt -y install java gcc python3 python3-pip
    apt -y install screen tar
    apt -y install vim
    apt -y install lsmod lsof
    cd ..
    mv vimrc /etc/
    cd centos
    apt -y update #����ȫ����װ��is same as apt upgarde
    pip3 install --upgrade pip
    echo -e "${Msg_Info}����������װ��ɣ�\\n"
    sleep 2
}

firewall_on() {
    systemctl start firewalld
    systemctl enable firewalld
    systemctl status firewalld
    firewall-cmd --zone=public --add-port=22/tcp --add-port=443/tcp --add-port=2443/tcp --add-port=26929/tcp --permanent
    firewall-cmd --reload
    firewall-cmd --list-ports
}

hardware_Check() {
    apt -y install lshw
}

system_Status() {
    curl -o /etc/apt.repos.d/konimex-neofetch-epel-7.repo https://copr.fedorainfracloud.org/coprs/konimex/neofetch/repo/epel-7/konimex-neofetch-epel-7.repo && \
    apt -y install neofetch redhat-lsb-core
}

mermory_check() {
    cat /etc/fstab
    fdisk -l
    df -h
    free -h
}

net_Check() {
    pip3 install speedtest_cli
    echo 0
    mkdir Speedtest_Shell && cd Speedtest_Shell && \
    wget https://ilemonra.in/LemonBenchIntl && mv LemonBenchIntl LemonBenchIntl.sh && chmod u+x LemonBenchIntl.sh && \
    cd ${START_PATH}
}

kernel_Update() {
    apt install -y https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm && \  #����epel-repoԴ centos7
    echo 0                                                                                 #     apt install -y https://www.elrepo.org/elrepo-release-8.0-2.el8.elrepo.noarch.rpm &&\
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org && \                        #������Կ
    apt clean all && rm -rf /var/cache/apt && \                                            #���yum����
    echo 0                                                                                 #     apt --disablerepo="*" --enablerepo="elrepo-kernel" list available | grep kernel-ml &&\  #��鵱ǰ�ܰ�װ���ں˰汾
    apt -y install --enablerepo=elrepo-kernel kernel-ml && \                               #��װ�����ں�
    echo '��GRUB_TIMEOUT=5 ��Ϊ 1 ���ȴ� 1 �������'
    vim /etc/default/grub && \                   #��GRUB_TIMEOUT=5 ��Ϊ 1 ���ȴ� 1 �������
    grub2-mkconfig -o /boot/grub2/grub.cfg && \  #�������������˵��б�
    echo '#ȷ������˳��index=0 ���ں˰汾Ӧ�õ��ڸոո��µ��ں˰汾��Ϊ��ȷ'
    grubby --info=ALL && \  #ȷ������˳��index=0 ���ں˰汾Ӧ�õ��ڸոո��µ��ں˰汾��Ϊ��ȷ
    read -p "enter the serial number of the recently installed kernel. [0/1/2...] " num && \
    grub2-set-default $num && \
    reboot_os
}

main() {
    clear
    mermory_check && \
    environment_Install && \
    firewall_on && \
    hardware_Check && \
    system_Status && \
    net_Check && \
    kernel_Update
    apt clean all #clean cache
}

mkdir logs && cd logs && df -h | tee -a memory.txt && free -h | tee -a memory.txt && \
cd ${START_PATH}
main 2>&1 | tee ${START_PATH}/system_config.txt
