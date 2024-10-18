#!/bin/bash

# Definir directorios de descarga e instalación
DOWNLOAD_DIR="/tmp"
BIN_DIR="/usr/local/bin"
LOG_FILE="/var/log/userdata.log"

# Función para loggear el éxito o error de cada comando
log_command() {
    "$@" >> $LOG_FILE 2>&1
    if [ $? -eq 0 ]; then
        echo "$1: Instalación exitosa" >> $LOG_FILE
    else
        echo "$1: Error en la instalación" >> $LOG_FILE
    fi
}

# Actualizar el sistema
echo "Actualizando el sistema..." >> $LOG_FILE
log_command sudo apt-get update -y

# Instalar AWS CLI
echo "Instalando AWS CLI..." >> $LOG_FILE
log_command sudo apt-get install unzip -y
log_command curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$DOWNLOAD_DIR/awscliv2.zip"
log_command sudo unzip "$DOWNLOAD_DIR/awscliv2.zip" -d "$DOWNLOAD_DIR"
log_command sudo "$DOWNLOAD_DIR/aws/install" -i /usr/local/aws-cli -b $BIN_DIR

# Configurar las claves de acceso de AWS CLI
echo "Configurando credenciales de AWS CLI..." >> $LOG_FILE
$BIN_DIR/aws configure set aws_access_key_id AKIAUND45NE57MU3BIVU
$BIN_DIR/aws configure set aws_secret_access_key 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
$BIN_DIR/aws configure set default.region us-east-1

# Verificar la configuración mediante una acción
echo "Listando buckets de S3 para verificar credenciales..." >> $LOG_FILE
$BIN_DIR/aws s3 ls >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "Configuración de AWS CLI verificada correctamente mediante acceso a S3" >> $LOG_FILE
else
    echo "Error en la verificación de configuración de AWS CLI" >> $LOG_FILE
fi

# Instalar kubectl
echo "Instalando kubectl..." >> $LOG_FILE
log_command curl -o "$DOWNLOAD_DIR/kubectl" -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
log_command sudo mv "$DOWNLOAD_DIR/kubectl" $BIN_DIR/kubectl
log_command sudo chmod +x $BIN_DIR/kubectl

# Instalar Helm
echo "Instalando Helm..." >> $LOG_FILE
HELM_VERSION="v3.6.3"
log_command curl -L "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz" -o "$DOWNLOAD_DIR/helm.tar.gz"
log_command sudo tar -zxvf "$DOWNLOAD_DIR/helm.tar.gz" -C $DOWNLOAD_DIR
log_command sudo mv "$DOWNLOAD_DIR/linux-amd64/helm" $BIN_DIR/helm
log_command sudo chmod +x $BIN_DIR/helm

# Instalar eksctl
echo "Instalando eksctl..." >> $LOG_FILE
log_command curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | sudo tar xz -C $BIN_DIR

# Mensaje de finalización
echo "Instalación completada. Revise el archivo de log en $LOG_FILE para los detalles."

# Verificar instalación:
# aws --version
# kubectl version --client
# eksctl version
# helm version
# aws configure list

