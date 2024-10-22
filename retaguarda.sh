#!/bin/bash
# Script de configuração Linux pós formatação 
# Data: 04/10/2023

# URLs dos aplicativos a serem baixados 
ANYDESK_URL="http://intranet.tupan.net/infra/anydesk.deb"
CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
TEAMVIEWER_URL="http://intranet.tupan.net/infra/teamviewer.deb"

# Adição de repositórios
sudo add-apt-repository ppa:emoraes25/cid -y
sudo add-apt-repository ppa:libreoffice/ppa -y
sudo add-apt-repository ppa:dawidd0811/neofetch -y

# Atualização dos repositórios
sudo apt update
sudo apt upgrade -y
sudo apt --fix-broken install -y

# Função para verificar e instalar um pacote
verificar_e_instalar_pacote() {
    local pacote=$1
    echo "Verificando e instalando $pacote..."
    if ! dpkg -l | grep -qii "$pacote"; then
        sudo apt install -y "$pacote"
        if [ $? -ne 0 ]; then
            echo "Falha ao instalar $pacote. Saindo..."
            exit 1
        fi
    else
        echo "$pacote já está instalado."
    fi
}

# Lista de pacotes a serem instalados
PACKAGES=(
    cid
    cid-gtk
    rdesktop
    vino
    samba
    gnome
    krb5-kdc
    libsecret-tools
    winbind
    kolourpaint
    smbclient
    cifs-utils
    libpam-mount
    ntp
    ntpdate
    libnss-winbind
    libpam-winbind
    ssh
    openssh-server
    conky-all
    default-jdk
    default-jre
    openjdk-8-jre
    software-properties-common
    apt-transport-https
    filezilla
    network-manager-l2tp
    network-manager-l2tp-gnome
    mythes-pt-pt
    mythes-pt-br
    thunderbird-locale-pt-pt
    thunderbird-locale-pt-br
    hunspell-pt-pt
    hunspell-pt-br
    hyphen-pt-pt
    hyphen-pt-br
    neofetch
)    
# Instalação dos pacotes
sudo apt install -y "${PACKAGES[@]}"

# Verificação e instalação dos pacotes
for pacote in "${PACKAGES[@]}"; do
    verificar_e_instalar_pacote "$pacote"
done

# Variável dos jogos
GAMES=(
    five-or-more
    gnome-2048
    gnome-klotski
    gnome-sudoku
    gnome-mahjongg
    gnome-mines
    gnome-nibbles
    quadrapassel
    four-in-a-row
    iagno
    gnome-robots
    swell-foop
    hitori
    tali
    gnome-taquin
    gnome-tetravex
    hoichess
    aisleriot
    lightsoff
    # Adicionar outros jogos aqui...
)

# Desinstalação dos jogos
for game in "${GAMES[@]}"; do
    sudo apt remove -y "$game"
done

# Ajuste do arquivo do NTP e Host
sed -i '9,$d' /etc/systemd/timesyncd.conf
echo -e "\n[Time]\nNTP=retaguarda.intra.net\nFallbackNTP=192.168.3.232" >> /etc/systemd/timesyncd.conf
sed -i 's/^hosts.*/hosts:\ \ \ \ \ \ \ \ \ \ files\ dns\ \mdsn4/' /etc/nsswitch.conf

# Instalação de Aplicativos
mkdir /opt/Icones /opt/Atalhos /opt/Config .config/autostart
mkdir /etc/skel/.config
mkdir /etc/skel/.config/autostart
mkdir /etc/skel/Área\ de\ Trabalho
sudo chmod -R 777 /opt/Icones
sudo chmod -R 777 /opt/Atalhos
sudo chmod -R 777 /opt/Config

# Baixar e instalar Aplicativos
wget "$ANYDESK_URL" -O anydesk.deb
sudo dpkg -i anydesk.deb
rm anydesk.deb

wget "$CHROME_URL" -O google-chrome.deb
sudo dpkg -i google-chrome.deb
rm google-chrome.deb

wget "$TEAMVIEWER_URL" -O teamviewer.deb
sudo dpkg -i teamviewer.deb
rm teamviewer.deb

# Repetir para os demais programas...

# Configuração do arquivo .conkyrc
if [ ! -f ".conkyrc" ]; then
    smbget smb://ti-distac:Tupaneh10@192.168.10.221/ti-distac/linux/Conky/conkyrc -o /opt/Config/.conkyrc
    cp -f /opt/Config/.conkyrc .conkyrc
    cp -f /opt/Config/.conkyrc /etc/skel/.conkyrc
fi

# Configuração do desktop do Conky
if [ ! -f "opt/conky.desktop" ]; then
    smbget smb://ti-distac:Tupaneh10@192.168.10.221/ti-distac/linux/Conky/conky.desktop -o /opt/Config/conky.desktop
    cp -f /opt/Config/conky.desktop .config/autostart/conky.desktop
    cp -f /opt/Config/conky.desktop /etc/skel/.config/autostart/conky.desktop && sleep 1 && chmod +x /etc/skel/.config/autostart/conky.desktop
fi

# Corrigir pacotes quebrados
sudo apt install -f -y
sudo apt --fix-broken install -y
sudo apt autoremove -y

# Sincronizar horário com o servidor
sudo service ntp stop
sudo ntpdate retaguarda.intra.net
sudo service ntp start

# Corrigindo bug do anydesk
sudo mv /usr/share/gnome-shell/extensions/ubuntu-appindicators@ubuntu.com/appIndicator.js /usr/share/gnome-shell/extensions/ubuntu-appindicators@ubuntu.com/appIndicator.bak

# Aplicando senha de acesso Anydesk
echo distac10 | anydesk --set-password

# Instalação do Agente do GLPI
cd /tmp/
	wget http://intranet.tupan.net/infra/glpiagentinstall.sh
		bash glpiagentinstall.sh 

# Instalação do Agente do BITDEFENDER
# cd /opt/
	# wget http://intranet.tupan.net/infra/installer
	# wget http://intranet.tupan.net/infra/installer.xml
	# wget http://intranet.tupan.net/infra/bdconfigure
		# ./installer
		
# Função para exibir uma barra de progresso
function exibir_progresso() {
    local intervalo=0.2
    local mensagem=$1
    local i=0
    local caracteres=('|' '/' '-' '\\')

    while true; do
        i=$(( (i + 1) % 4 ))
        echo -ne "\r$mensagem ${caracteres[$i]}"
        sleep $intervalo
    done
}

# Processo de ingresso no domínio
echo "Ingresso no Domínio:"
read -p "Nome de usuário: " DOMAIN_USER
read -s -p "Senha: " DOMAIN_PASS

# Iniciar a função de exibição do progresso em segundo plano
exibir_progresso "Ingressando no domínio... " &

# Armazenar o PID da função de progresso
PID_PROGRESSO=$!

# Executar o ingresso no domínio
sudo cid join domain=retaguarda.intra.net user=$DOMAIN_USER pass=$DOMAIN_PASS --no-kerberos

# Parar a função de exibição do progresso
kill $PID_PROGRESSO > /dev/null 2>&1

# Pergunta sobre reinicialização
while true; do
  echo -e "\nDeseja reiniciar a máquina agora? (y/n)"
  read -r RESTART_OPTION

  case $RESTART_OPTION in
    [Yy])
      reboot
      ;;
    [Nn])
      echo "Você optou por reiniciar manualmente após o ingresso no domínio."
      echo "Lembre-se de reiniciar o sistema para aplicar as configurações."
      break
      ;;
    *)
      echo "Opção inválida. Por favor, digite 'y' para sim ou 'n' para não."
      ;;
  esac
done
