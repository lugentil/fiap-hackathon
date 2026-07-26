aws_region   = "us-west-2"
project_name = "solidarytech-dr"
vpc_cidr     = "10.1.0.0/16"

eks_node_desired = 1

db_passwords = {
  auth_db     = ""
  donation_db = ""
}
