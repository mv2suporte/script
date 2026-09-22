# Docker install
apt update && apt install curl -y

sleep 5

curl -fsSL https://raw.githubusercontent.com/mv2suporte/script/main/docker_install.sh | bash


# PhpIpam install
wget https://raw.githubusercontent.com/mv2suporte/script/main/phpipam_install.sh

chmod a+x phpipam_install.sh

./phpipam_install.sh

Usuário do banco = phpipam

Senha do banco = phpipamadmin

# MUDAR A TELA DE LOGIN DO LINUX

curl -fsSL https://raw.githubusercontent.com/mv2suporte/script/refs/heads/main/20-mv2 -o /etc/update-motd.d/20-mv2 && chmod +x /etc/update-motd.d/20-mv2 && /etc/update-motd.d/20-mv2
