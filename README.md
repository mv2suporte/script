# Docker install
apt update && aptinstall curl \
sleep 5
curl -fsSL https://raw.githubusercontent.com/mv2suporte/script/main/docker_install.sh | bash


# PhpIpam install
wget https://raw.githubusercontent.com/mv2suporte/script/main/phpipam_install.sh

chmod a+x phpipam_install.sh

./phpipam_install.sh

Usuário do banco = phpipam

Senha do banco = phpipamadmin
