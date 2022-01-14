#!/usr/bin/env bash
#클러스터를 구성하기 위해서 가상 머신에 설치돼야 하는 의존성 패키지를 명시, 실습에 필요한 소스코드를 특정 가상머신(m-k8s) 내부에 내려받도록 설정
# install packages 
yum install epel-release -y
yum install vim-enhanced -y
yum install git -y				#깃허브에서 코드를 내려받을 수 있게 git 설치

# install docker 
yum install docker -y && systemctl enable --now docker	#쿠버네티스를 관리하는 컨테이너를 설치하기 위해 도커를 설치하고 구동

# install kubernetes cluster 
yum install kubectl-$1 kubelet-$1 kubeadm-$1 -y
systemctl enable --now kubelet
#쿠버네티스를 구성하기 위해 첫번째 변수 ($1 = Ver = '1.18.4')로 넘겨받은 1.18.4 버전의 kubectl , kubelet , kubeadm 를 설치하고 kubelet 시작
# git clone _Book_k8sInfra.git 
if [ $2 = 'Main' ]; then
  git clone https://github.com/sysnet4admin/_Book_k8sInfra.git
  mv /home/vagrant/_Book_k8sInfra $HOME
  find $HOME/_Book_k8sInfra/ -regex ".*\.\(sh\)" -exec chmod 700 {} \;
fi
#전체 실행 코드를 마스터 노드에만 내려받을 수 있도록 Vagrantfile에서 두번째 변수 ($2 = 'Main')를 넘겨 받음
#깃에서 코드를 내려받아 실습을 진행할 루트 홈디렉토리 (/root)로 옮김
#.sh 를 find로 찾아서 바로 실행가능한 상태가 되도록 chmod 700으로 설정
