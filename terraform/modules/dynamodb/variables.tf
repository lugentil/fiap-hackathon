variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
  default     = "SolidaryTechDonations"
}

variable "hash_key" {
  description = "Chave de particao da tabela"
  type        = string
  default     = "event_id"
}
