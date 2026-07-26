terraform {
  backend "s3" {
    bucket         = "tech-challenge-solidarytech-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}