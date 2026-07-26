resource "kubernetes_namespace" "services" {
  for_each = toset([
    "auth-service",
    "ngo-service",
    "volunteer-service",
    "donation-service",
    "report-service"
  ])

  metadata {
    name = each.key
  }
}

resource "kubernetes_secret" "auth_service" {
  metadata {
    name      = "auth-service-secrets"
    namespace = kubernetes_namespace.services["auth-service"].metadata[0].name
  }

  data = {
    DATABASE_URL = "postgres://postgres:${var.db_passwords["auth_db"]}@${module.rds_auth.endpoint}/auth_db"
    MASTER_KEY   = var.master_key
  }
}

resource "kubernetes_secret" "ngo_service" {
  metadata {
    name      = "ngo-service-secrets"
    namespace = kubernetes_namespace.services["ngo-service"].metadata[0].name
  }

  data = {
    DATABASE_URL     = "postgres://postgres:${var.db_passwords["ngo_db"]}@${module.rds_ngo.endpoint}/ngo_db"
    AUTH_SERVICE_URL = "http://auth-service.auth-service.svc:8001"
  }
}

resource "kubernetes_secret" "volunteer_service" {
  metadata {
    name      = "volunteer-service-secrets"
    namespace = kubernetes_namespace.services["volunteer-service"].metadata[0].name
  }

  data = {
    AWS_DYNAMODB_TABLE = module.dynamodb_volunteers.table_name
    AUTH_SERVICE_URL   = "http://auth-service.auth-service.svc:8001"
  }
}

resource "kubernetes_secret" "donation_service" {
  metadata {
    name      = "donation-service-secrets"
    namespace = kubernetes_namespace.services["donation-service"].metadata[0].name
  }

  data = {
    DATABASE_URL     = "postgres://postgres:${var.db_passwords["donation_db"]}@${module.rds_donation.endpoint}/donation_db"
    PORT             = "8004"
    AUTH_SERVICE_URL = "http://auth-service.auth-service.svc:8001"
    AWS_SQS_URL      = module.sqs.queue_url
  }
}

resource "kubernetes_secret" "report_service" {
  metadata {
    name      = "report-service-secrets"
    namespace = kubernetes_namespace.services["report-service"].metadata[0].name
  }

  data = {
    PORT               = "8005"
    AWS_SQS_URL        = module.sqs.queue_url
    AWS_DYNAMODB_TABLE = module.dynamodb.table_name
  }
}

resource "kubernetes_secret" "aws_credentials_donation" {
  metadata {
    name      = "aws-credentials"
    namespace = kubernetes_namespace.services["donation-service"].metadata[0].name
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_credentials.access_key
    AWS_SECRET_ACCESS_KEY = var.aws_credentials.secret_key
    AWS_SESSION_TOKEN     = var.aws_credentials.session_token
    AWS_REGION            = var.aws_region
  }
}

resource "kubernetes_secret" "aws_credentials_report" {
  metadata {
    name      = "aws-credentials"
    namespace = kubernetes_namespace.services["report-service"].metadata[0].name
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_credentials.access_key
    AWS_SECRET_ACCESS_KEY = var.aws_credentials.secret_key
    AWS_SESSION_TOKEN     = var.aws_credentials.session_token
    AWS_REGION            = var.aws_region
  }
}

resource "kubernetes_secret" "aws_credentials_volunteer" {
  metadata {
    name      = "aws-credentials"
    namespace = kubernetes_namespace.services["volunteer-service"].metadata[0].name
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_credentials.access_key
    AWS_SECRET_ACCESS_KEY = var.aws_credentials.secret_key
    AWS_SESSION_TOKEN     = var.aws_credentials.session_token
    AWS_REGION            = var.aws_region
  }
}
