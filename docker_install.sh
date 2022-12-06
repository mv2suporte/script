#!/bin/bash
apt install screen figlet toilet cowsay -y > /dev/null
rm /tmp/finish
figlet -c "Script"
figlet -c "de"
figlet -c "Instalacao"
figlet -c "DOCKER"
echo "Mv2 SOLUTIONS SUPORTE E CONSULTORIA EM TI http://mv2.solutions (24)99841-1506"
apt update
apt install -y htop mtr
sleep 5
wget https://raw.githubusercontent.com/mv2suporte/docker/main/profile
echo
echo
echo "GERANDO ATALHOS DOCKER"
echo
sleep 3
mv profile /etc/profile
sleep 3
echo "INICIANDO O PROCESSO DE INSTALAÇÃO DO DOCKER"
sleep 3
echo
echo
apt remove docker docker-engine docker.io
apt install curl -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sleep 3
echo
echo
echo "DOCKER INSTALADO"
sleep 2
echo "ALTERANDO O GRUB"
sleep 2
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 quiet"/g' /etc/default/grub
update-grub
sleep 2
echo "INSTALANDO O PORTAINER"
sleep 2
echo
echo
echo
docker run -d --restart always -p 9000:9000 --name Portainer -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
sleep 2
echo
echo
echo "INSTALANDO O DOCKER COMPROSE"
echo
echo
sleep 3
echo
echo
curl -L https://github.com/docker/compose/releases/download/1.25.1-rc1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sleep 2
chmod +x /usr/local/bin/docker-compose
echo
echo
echo "ALTERANDO AS PROPRIEDADES DE REDE"
sleep 3
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
echo
echo
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
echo
echo
figlet -c "DOCKER INSTALADO COM SUCESSO"
echo "o sistema irá reinicializar para aplicar todas as configurações"
echo
echo
sleep 10
reboot
