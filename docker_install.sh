#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Execute este script como root ou usando sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

rm -f /tmp/finish

apt update
apt install -y screen figlet toilet cowsay htop mtr net-tools dnsutils curl

clear
figlet -c "Script"
figlet -c "de"
figlet -c "Instalacao"
figlet -c "DOCKER"

echo "Mv2 SOLUCOES"
sleep 3

echo
echo "GERANDO ATALHOS DOCKER"
echo

# Remove o bloco antigo para evitar atalhos duplicados
sed -i '/# INICIO ATALHOS DOCKER/,/# FIM ATALHOS DOCKER/d' /etc/profile

cat >> /etc/profile <<'EOF'

# INICIO ATALHOS DOCKER
# Atalhos Docker
alias ddelall='docker rm $(docker ps -qa) -f'
alias ddelalli='docker rmi $(docker images -q)'
alias ddelallv='docker volume prune -f'
alias dpa='docker ps -a'
alias dp='docker ps'
alias di='docker images'
alias d='docker'
alias dr='docker run -it'
alias de='docker exec -it'
alias brewski='brew update && brew upgrade && brew cleanup; brew doctor'
alias dcc='docker compose'
alias dcb='docker compose build'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias clear='clear -x'
# FIM ATALHOS DOCKER
EOF

echo "ATALHOS DOCKER CONFIGURADOS"
sleep 3

echo
echo "INICIANDO O PROCESSO DE INSTALAÇÃO DO DOCKER"
echo
sleep 3

# Remove versões antigas do Docker, caso estejam instaladas
apt remove -y \
    docker \
    docker-engine \
    docker.io \
    containerd \
    runc 2>/dev/null || true

curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh
rm -f /tmp/get-docker.sh

sleep 3
echo
echo "DOCKER INSTALADO"
sleep 2

echo
echo "INSTALANDO O DOCKER COMPOSE"
echo
sleep 3

apt install -y docker-compose-plugin

echo
echo "CONFIGURANDO O DOCKER PARA INICIAR COM O SISTEMA"
echo

systemctl enable docker
systemctl restart docker

echo
echo "ALTERANDO O GRUB"
echo
sleep 2

if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
    sed -i \
        's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 quiet"/' \
        /etc/default/grub
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 quiet"' \
        >> /etc/default/grub
fi

update-grub
sleep 2

echo
echo "INSTALANDO O PORTAINER"
echo
sleep 2

# Remove um contêiner Portainer antigo, caso exista
if docker ps -a --format '{{.Names}}' | grep -qx 'portainer'; then
    docker rm -f portainer
fi

docker volume create portainer_data

docker run -d \
    --name portainer \
    --restart=always \
    -p 8000:8000 \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

sleep 2

echo
echo "ALTERANDO AS PROPRIEDADES DE REDE"
echo
sleep 3

cat > /etc/sysctl.d/99-docker-forwarding.conf <<'EOF'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

sysctl --system

echo
figlet -c "DOCKER INSTALADO COM SUCESSO"
echo
echo "O sistema será reinicializado em 10 segundos para aplicar as configurações."
echo "Pressione CTRL+C para cancelar a reinicialização."
echo

sleep 10
reboot
