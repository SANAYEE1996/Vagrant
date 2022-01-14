#!/usr/bin/env bash
#kubeadm으로 쿠버네티스를 설치하기 위한 사전 조건을 설정하는 스크립트 파일// 쿠버네티스의 노드가 되는 가상머신에 값들을 설정함.
# vim configuration 
echo 'alias vi=vim' >> /etc/profile #vi를 호출 하면 vim을 호출하도록 프로파일에 입력, 코드에 하이라이트를 넣어 코드를 쉽게 구분 가능

# swapoff -a to disable swapping
swapoff -a							#쿠버네티스의 설치 요구 조건을 맞추기 위해 스왑되지 않도록 설정함
# sed to comment the swap partition in /etc/fstab
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab	# 시스템이 시작되더라도 스왑되지 않도록 설정함

# kubernetes repo
gg_pkg="packages.cloud.google.com/yum/doc" # 쿠버네티스의 Repository를 설정하기 위한 경로가 너무 길어지지 않게 경로를 변수로 처리
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://${gg_pkg}/yum-key.gpg https://${gg_pkg}/rpm-package-key.gpg
EOF
#쿠버네티스를 내려받을 Repository를 설정하는 구문
# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
# selinux가 제한적으로 사용되지 않도록 permissive 모드로 변경
# RHEL/CentOS 7 have reported traffic issues being routed incorrectly due to iptables bypassed
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
#브리지 네트워크를 통과하는 IPv4 와 IPv6의 패킷을 iptables가 관리하게 설정
#파드 (쿠버네티스에서 실해되는 객체의 최소 단위)의 통신을 iptables단위로 관리
#필요에 따라 IPVS 같은 방식으로도 구성할 수 있음
modprobe br_netfilter
#br_netfilter 커널 모듈을 사용해 브리지로 네트워크를 구성할
#이때 IP Masquerade를 사용해 내부 네트워크와 외부 네트워크를 분리
#Masquerade - 커널에서 제공하는 NAT 기능
#br_netfilter 를 적용함으로써 28~31번째 줄에서 적용한 iptables가 활성화 됌

# local small dns & vagrant cannot parse and delivery shell code.
echo "192.168.1.10 m-k8s" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.1.10$i w$i-k8s" >> /etc/hosts; done
#쿠버네티스 안에서 노드간 통신을 이름으로 할 수 있도록 각 노드의 호스트 이름과 IP를 /etc/hosts에 설정함
#이때 워커 노드는 Vagrantfile에서 넘겨 받은 N 변수로 전달 된 노드 수에 맞게 동적으로 생성


# config DNS  
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF
#외부와 설정할 수 있게 DNS 서버를 지정

