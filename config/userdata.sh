#!/bin/bash
set -e

# Definir directorios de descarga y binarios
DOWNLOAD_DIR="/tmp"
BIN_DIR="/usr/local/bin"

# Actualizar el sistema
sudo apt-get update -y

# Instalar el agente de SSM
sudo snap install amazon-ssm-agent --classic

# Iniciar y habilitar el agente SSM para que se inicie automáticamente al arrancar
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Instalar AWS CLI
sudo apt-get install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$DOWNLOAD_DIR/awscliv2.zip"
sudo unzip "$DOWNLOAD_DIR/awscliv2.zip" -d "$DOWNLOAD_DIR"
sudo "$DOWNLOAD_DIR/aws/install" -i /usr/local/aws-cli -b $BIN_DIR
sudo rm -rf "$DOWNLOAD_DIR/awscliv2.zip" "$DOWNLOAD_DIR/aws"

# Instalar kubectl
curl -o "$DOWNLOAD_DIR/kubectl" -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo mv "$DOWNLOAD_DIR/kubectl" $BIN_DIR/kubectl
sudo chmod +x $BIN_DIR/kubectl

# Instalar Helm
HELM_VERSION="v3.6.3"
curl -L "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz" -o "$DOWNLOAD_DIR/helm.tar.gz"
sudo tar -zxvf "$DOWNLOAD_DIR/helm.tar.gz" -C $DOWNLOAD_DIR
sudo mv "$DOWNLOAD_DIR/linux-amd64/helm" $BIN_DIR/helm
sudo chmod +x $BIN_DIR/helm
sudo rm -rf "$DOWNLOAD_DIR/helm.tar.gz" "$DOWNLOAD_DIR/linux-amd64"

# Verificar instalaciones (opcional)
# aws --version
# kubectl version --client
# helm version
