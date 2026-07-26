variable "aws_region" {
  description = "Regiao secundaria do warm standby"
  default     = "us-west-2"
}

variable "aws_availability_zones" {
  description = "Lista de AZs da regiao secundaria"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "project_name" {
  description = "Nome do projeto para os recursos do ambiente espelho"
  default     = "solidarytech-dr"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC do espelho (nao pode colidir com a primaria)"
  default     = "10.1.0.0/16"
}

variable "eks_node_instance_type" {
  description = "Instancia EC2 dos nodes (capacidade reduzida no standby)"
  default     = "t3.medium"
}

variable "eks_node_desired" {
  description = "Quantidade de nodes do standby"
  default     = 1
}

variable "eks_node_min" {
  description = "Quantidade minima de nodes"
  default     = 1
}

variable "eks_node_max" {
  description = "Quantidade maxima de nodes (escala apos o failover)"
  default     = 3
}

variable "rds_instance_class" {
  description = "Shape dos bancos PostgreSQL do espelho"
  default     = "db.t3.micro"
}

variable "db_passwords" {
  description = "Senhas dos bancos criticos (mesmas chaves da regiao primaria)"
  type        = map(string)
  sensitive   = true
  default     = null

  validation {
    condition = try(alltrue([
      for key in ["auth_db", "donation_db"] :
      contains(keys(var.db_passwords), key) && try(length(trimspace(var.db_passwords[key])) >= 8, false)
    ]), false)
    error_message = "Preencha db_passwords em terraform.tfvars com as chaves auth_db e donation_db. Cada senha precisa ter pelo menos 8 caracteres."
  }
}

variable "finops_tags" {
  description = "Tags FinOps do ambiente de DR"
  type        = map(string)
  default = {
    Project     = "SolidaryTech"
    Environment = "DR"
    CostCenter  = "NGO-Core"
    ManagedBy   = "Terraform"
  }
}
