aws_region   = "us-east-1"
project_name = "solidarytech"
environment  = "production"

finops_tags = {
  Project     = "SolidaryTech"
  Environment = "Production"
  CostCenter  = "NGO-Core"
  ManagedBy   = "Terraform"
}
vpc_cidr               = "10.0.0.0/16"
eks_node_instance_type = "t3.medium"
eks_node_desired       = 2
eks_node_min           = 1
eks_node_max           = 3
rds_instance_class     = "db.t3.micro"

db_passwords = {
  auth_db     = ""
  ngo_db      = ""
  donation_db = ""
}

master_key      = "solidarytech-master-key-faculdade"
gitops_repo_url = "https://github.com/lugentil/fiap-hackathon.git"

aws_credentials = {
  access_key    = ""
  secret_key    = ""
  session_token = ""
}

newrelic_license_key   = ""
newrelic_account_id    = "" 
newrelic_api_key       = ""
grafana_admin_password = ""
discord_webhook_url    = ""
pagerduty_routing_key  = ""
github_dispatch_token  = ""
github_repo_full_name  = "lugentil/fiap-hackathon"