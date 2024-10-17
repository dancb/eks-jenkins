variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "eks-cluster-jenkins"
}

variable "node_instance_type" {
  default = "t3.large"
}

variable "desired_capacity" {
  default = 1
}

variable "max_size" {
  default = 2
}

variable "min_size" {
  default = 1
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "volume_size" {
  description = "El tamaño del volumen EBS en GB para el nodo."
  default     = 40  # Ajusta este valor según tus necesidades
}

variable "public_subnet_cidrs" {
  default = ["10.0.3.0/25", "10.0.3.128/25"]
}
