# Generación del par de claves dentro de Terraform
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.cluster_name}-bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

# Guardar la clave privada en un archivo en config/
resource "local_file" "bastion_private_key" {
  content  = tls_private_key.bastion_key.private_key_pem
  filename = "config/bastion-private-key.pem"
}

# Security Group para el bastion host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.cluster_name}-bastion-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH desde cualquier IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Considera limitar esto a tu IP de administración
  }

  egress {
    description = "Permitir trafico de salida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-bastion-sg"
  }
}

# IAM Role para el bastion host
resource "aws_iam_role" "bastion_iam_role" {
  name = "${var.cluster_name}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Adjuntar políticas necesarias para acceso a EKS y permisos de SSM
resource "aws_iam_role_policy_attachment" "bastion_eks_policies" {
  count      = 4
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = element([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ], count.index)
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.cluster_name}-bastion-profile"
  role = aws_iam_role.bastion_iam_role.name
}

# Configuración del bastion host
resource "aws_instance" "bastion" {
  ami                         = "ami-08c40ec9ead489470"  # AMI de Ubuntu en us-east-1
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  # Cargar el user_data desde un archivo
  user_data = filebase64("config/userdata-v2.sh")

  tags = {
    Name = "${var.cluster_name}-bastion"
  }
}
