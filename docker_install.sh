#!/bin/bash

apt install screen figlet toilet cowsay -y > /dev/null

rm -f /tmp/finish

figlet -c "Script"
figlet -c "de"
figlet -c "Instalacao"
figlet -c "DOCKER"

echo "Mv2 SOLUTIONS SUPORTE E CONSULTORIA EM TI http://mv2.solutions (24)99841-1506"

echo
echo "ATUALIZANDO O SISTEMA"
echo

apt update
apt install -y htop mtr curl wget

sleep 3

wget -O /tmp/profile https://raw.githubusercontent.com/mv2suporte/script/main/profile

echo
echo "GERANDO ATALHOS DOCKER"
echo

sleep 2

mv /tmp/profile /etc/profile

sleep 2

echo
echo "INICIANDO O PROCESSO DE INSTALAÇÃO DO DOCKER"
echo

sleep 3

# Remove versões antigas caso existam
apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null

echo
echo "BAIXANDO INSTALADOR OFICIAL DO DOCKER"
echo

curl -fsSL https://get.docker.com -o /tmp/get-docker.sh

sh /tmp/get-docker.sh

rm -f /tmp/get-docker.sh

sleep 3

echo
echo "INSTALANDO DOCKER COMPOSE V2"
echo

apt update
apt install -y docker-compose-plugin

sleep 2

echo
echo "VERSAO DO DOCKER:"
docker --version

echo
echo "VERSAO DO DOCKER COMPOSE:"
docker compose version

sleep 3

echo
echo "ALTERANDO O GRUB"
echo

sleep 2

sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 quiet"/g' /etc/default/grub

update-grub

sleep 2

echo
echo "INSTALANDO O PORTAINER CE"
echo

sleep 2

docker run -d \
  --name portainer \
  --restart=always \
  -p 8000:8000 \
  -p 9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

sleep 3

echo
echo "ALTERANDO AS PROPRIEDADES DE REDE"
echo

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf

# Garante as configurações mesmo caso as linhas não existam
grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
grep -q '^net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf || echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf

sysctl -p

echo
echo

figlet -c "DOCKER INSTALADO COM SUCESSO"

echo
echo "Docker:"
docker --version

echo
echo "Docker Compose:"
docker compose version

echo
echo "Portainer:"
echo "https://IP_DO_SERVIDOR:9443"

echo
echo "O sistema irá reinicializar para aplicar todas as configurações."
echo

sleep 10

reboot
