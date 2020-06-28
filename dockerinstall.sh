#!/bin/bash

output(){
    echo -e '\e[36m'$1'\e[0m';
}

preflight(){
    output "RHEL/CentOS 8 Docker Skrypt instalacyjny"
    output "Copyright © 2020 Oliwier Zajaczkowski (SkyyDEV)."
    output "==============="
    output "Uzyj kodu naDSC.pl na lvlup.pro"
    output "aby dostac 10% rabatu na serwery VPS"
    output "Prosze wybrac typ twojej instalacji:"
    output "==============="
    output ""
}

os_detection(){
    output "Sprawdzanie twojego systemu"
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
        dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
        if [ $lsb_dist = "rhel" ]; then
            dist_version="$(echo $dist_version | awk -F. '{print $1}')"
        fi
    else
        exit 1
    fi
    
    if [ "$lsb_dist" =  "centos" ] || [ "$lsb_dist" =  "rhel" ]; then    
        if [ "$dist_version" = "8" ]; then
            if [ "$lsb_dist" =  "rhel" ]; then
                output "Red Hat Enterprise Linux 8 Wykryto. Dobrze!"
            else
                output "CentOS 8 Wykryty. Dobrze!"
            fi
        else
            output "Nie wspierany system operacyjny. Prosze uzyc RHEL/CentOS 8."
        fi
    else 
       output "NNie wspierany system operacyjny. Prosze uzyc RHEL/CentOS 8."
       exit 1
    fi
}

install_docker(){
  dnf install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.2.el7.x86_64.rpm
  dnf install -y dnf-utils device-mapper-persistent-data lvm2
  dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y docker-ce --nobest
  systemctl enable docker
  systemctl start docker
}

firewalld_fix(){
  if ! [ -x "$(command -v firewall-cmd)" ]; then
     output "Firewalld detected. Adding rules to make sure firewalld works with Docker."
     firewall-cmd --change-interface=docker0 --permanent
     firewall-cmd --zone=trusted --add-masquerade --permanent
     firewall-cmd --reload
  fi
}

preflight
os_detection
install_docker