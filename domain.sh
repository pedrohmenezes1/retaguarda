#!/bin/bash
# Script de configuração Linux pós formatação 
# Data: 22/10/2024

# Alterar o nome da máquina
echo "Digite o novo nome da máquina: "
read NEW_HOSTNAME
echo "Você digitou: $NEW_HOSTNAME. Está correto? (y/n)"
read -r CONFIRMATION

if [[ "$CONFIRMATION" == "y" || "$CONFIRMATION" == "Y" ]]; then
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"
    echo "Nome da máquina alterado para: $NEW_HOSTNAME"
else
    echo "Nome da máquina não foi alterado. Execute o script novamente se precisar alterar."
    exit 1
fi

# Processo de ingresso no domínio
echo "Ingresso no Domínio com usuário padrão ubuntu..."

# Definir as credenciais de usuário e senha
DOMAIN_USER="ubuntu"
DOMAIN_PASS="Ubuntu@1025"

# Iniciar a função de exibição do progresso em segundo plano
exibir_progresso "Ingressando no domínio... " &

# Armazenar o PID da função de progresso
PID_PROGRESSO=$!

# Executar o ingresso no domínio com as credenciais predefinidas
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

