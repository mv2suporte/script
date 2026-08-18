#!/bin/bash

set -Eeuo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "ERRO: execute este script como root ou usando sudo."
    exit 1
fi

if [ ! -r /etc/os-release ]; then
    echo "ERRO: não foi possível identificar o sistema operacional."
    exit 1
fi

. /etc/os-release

if [ "${ID:-}" != "debian" ] || [ "${VERSION_ID:-}" != "13" ]; then
    echo "ERRO: este instalador foi preparado para Debian 13."
    echo "Sistema detectado: ${PRETTY_NAME:-desconhecido}"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "Atualizando os repositórios e instalando dependências..."
apt-get update
apt-get install -y ca-certificates curl htop mtr-tiny net-tools dnsutils

echo "Removendo pacotes que podem conflitar com o Docker oficial..."
for pacote in docker.io docker-compose docker-doc docker-buildx podman-docker containerd runc; do
    if dpkg-query -W -f='${db:Status-Abbrev}' "$pacote" 2>/dev/null | grep -q '^ii'; then
        apt-get remove -y "$pacote"
    fi
done

echo "Configurando o repositório oficial do Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME:-trixie}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "Instalando Docker Engine e Docker Compose..."
apt-get update
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable --now docker

echo "Criando atalhos Docker..."
cat > /etc/profile.d/docker-aliases.sh <<'EOF'
# Atalhos Docker
alias ddelall='docker rm $(docker ps -qa) -f'
alias ddelalli='docker rmi $(docker images -q)'
alias ddelallv='docker volume prune'
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
EOF
chmod 0644 /etc/profile.d/docker-aliases.sh

echo "Instalando o MOTD personalizado..."
cat > /etc/update-motd.d/20-mv2 <<'MOTD_EOF'
#!/bin/bash

upSeconds=$(cut -d. -f1 /proc/uptime)
secs=$((upSeconds%60))
mins=$((upSeconds/60%60))
hours=$((upSeconds/3600%24))
days=$((upSeconds/86400))
UPTIME=$(printf "%d dias, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs")

read one five fifteen rest < /proc/loadavg

HOSTNAME=$(hostname)
OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)
CPU=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ //')
VCPU=$(nproc)
MEMFREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEMTOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
DISK=$(df -h / | awk 'NR==2 {print $3 " usados / " $4 " livres (" $5 ")"}')
IPV4=$(ip -4 addr show scope global | awk '/inet / {print $2}' | head -1)
IPV6=$(ip -6 addr show scope global | awk '/inet6 / {print $2}' | head -1)
MAC=$(ip link | awk '/link\/ether/ {print $2}' | head -1)
PROCS=$(ps ax --no-headers | wc -l)

SEP_COL=50
TOTAL_COL=120

line_full() {
    printf '%*s\n' "$TOTAL_COL" '' | tr ' ' '-'
}

print_line() {
    printf "%s" "$1"
    printf "\033[%sG| %s\n" "$SEP_COL" "$2"
}

echo
line_full

print_line '        ███╗   ███╗██╗   ██╗██████╗ ' "Data/Hora..........: $(date '+%d/%m/%Y %H:%M:%S')"
print_line '        ████╗ ████║██║   ██║╚════██╗' "Hostname...........: ${HOSTNAME}"
print_line '        ██╔████╔██║██║   ██║ █████╔╝' ""
print_line '        ██║╚██╔╝██║╚██╗ ██╔╝██╔═══╝ ' "Sistema............: ${OS}"
print_line '        ██║ ╚═╝ ██║ ╚████╔╝ ███████╗' "Kernel.............: ${KERNEL}"
print_line '        ╚═╝     ╚═╝  ╚═══╝  ╚══════╝' ""

print_line '' "Uptime.............: ${UPTIME}"
print_line '         CONSULTORIA E SUPORTE EM TI' "CPU................: ${CPU}"
print_line '' "vCPU...............: ${VCPU}"
print_line '----------------------------------------' "Load...............: ${one}, ${five}, ${fifteen}"
print_line '' ""

print_line 'MV2 Solucoes' "Memoria............: ${MEMFREE}kB Livre / ${MEMTOTAL}kB Total"
print_line 'Consultoria e Suporte em TI' "Disco..............: ${DISK}"
print_line 'https://mv2solutions.com.br' ""
print_line 'WhatsApp: (24) 99912-6059' "IPv4...............: ${IPV4}"
print_line '' "IPv6...............: ${IPV6}"
print_line '' "MAC................: ${MAC}"
print_line '' ""
print_line '' "Processos..........: ${PROCS}"

line_full
echo
MOTD_EOF
chmod 0755 /etc/update-motd.d/20-mv2

echo "Preparando os dados persistentes dos containers..."
docker volume create portainer_data >/dev/null
install -d -m 0755 /opt/nginx-proxy-manager/data
install -d -m 0755 /opt/nginx-proxy-manager/letsencrypt

if docker container inspect portainer >/dev/null 2>&1; then
    echo "Substituindo o container Portainer existente..."
    docker rm -f portainer >/dev/null
fi

echo "Instalando o Portainer..."
docker run -d \
    --name portainer \
    --restart=always \
    -p 8000:8000 \
    -p 9000:9000 \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

if docker container inspect Proxy-reverso >/dev/null 2>&1; then
    echo "Substituindo o container Proxy-reverso existente..."
    docker rm -f Proxy-reverso >/dev/null
fi

echo "Instalando o Nginx Proxy Manager..."
docker run -d \
    --name Proxy-reverso \
    --restart=always \
    -p 80:80 \
    -p 81:81 \
    -p 443:443 \
    -v /opt/nginx-proxy-manager/data:/data \
    -v /opt/nginx-proxy-manager/letsencrypt:/etc/letsencrypt \
    jc21/nginx-proxy-manager:latest
    
echo
echo "Instalação concluída com sucesso."
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker compose version)"
echo "Portainer: https://${IPV4}:9443"
echo "Nginx Proxy Manager: http://${IPV4}:81"
echo
