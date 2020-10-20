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

Hardware_Check() {
    lshw -version
    lshw -short
    cat /proc/cpuinfo
}

System_Status() {
    neofetch
    lsb_release -a #ϵͳ��Ϣ

    uname ��a
    cat /proc/version #Linux�鿴��ǰ����ϵͳ�汾��Ϣ
}

Mermory_check() {
    cat /etc/fstab
    fdisk -l
    df -h
    free -h
}

Net_Check() {
    speedtest
    curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast #LemonBench;Ӳ��������ѹ������
    # curl -fsL https://ilemonrain.com/download/shell/LemonBench.sh | bash
}

BBR_TCP_ON() {
    local param=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
    if [[ x"${param}" != x"bbr" ]]; then
        modprobe tcp_bbr
        echo "tcp_bbr" >>/etc/modules-load.d/modules.conf
        echo "net.core.default_qdisc=fq" >>/etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.conf
        sysctl -p
    else
        echo "${Msg_Info}bbr already installed, Nothing to do...\n"
    fi

}

BBR_Check() {
    lsmod | grep bbr
    sysctl net.ipv4.tcp_available_congestion_control
    sysctl net.ipv4.tcp_congestion_control

    echo -e "${Msg_Success}\ntcp_bbr\nnet.ipv4.tcp_available_congestion_control = reno cubic bbr\nnet.ipv4.tcp_congestion_control = bbr"
}

Main() {
    BBR_TCP_ON
    BBR_Check

    Hardware_Check
    System_Status
    Mermory_check
    Net_Check

    yum clean all #clean cache
}

cd logs && df -h | tee -a memory.txt && free -h | tee -a memory.txt && cd && START_PATH
echo -e "${Msg_Info}The system will making a performance report."
read -p "Do you really want to get a performance report?[y/n]" keepon
if [[ ${keepon} == "y" || ${keepon} == "Y" ]]; then
    Main 2>&1 | tee -a ${START_PATH}/system_performance.txt
else
    echo -e "${Msg_Info}Performance Testing is canceled..."
    exit 0
fi
