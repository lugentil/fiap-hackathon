output "eks_cluster_name" {
  description = "Nome do cluster EKS do espelho"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS do espelho"
  value       = module.eks.cluster_endpoint
}

output "rds_auth_endpoint" {
  description = "Endpoint do RDS de autenticacao no espelho"
  value       = module.rds_auth.endpoint
}

output "rds_donation_endpoint" {
  description = "Endpoint do RDS de doacoes no espelho"
  value       = module.rds_donation.endpoint
}

output "sqs_queue_url" {
  description = "URL da fila SQS do espelho"
  value       = module.sqs.queue_url
}

output "vpc_id" {
  description = "ID da VPC do espelho"
  value       = module.networking.vpc_id
}
