resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "nginx"
  }

  depends_on = [module.eks]
}

resource "helm_release" "ingress_nginx" {
  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = "4.9.1"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = join("\\,", module.networking.public_subnet_ids)
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
  }

  # o NLB e criado pelo cloud provider do EKS, entao o default_tags do Terraform nao alcanca ele
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = join("\\,", [for chave, valor in var.finops_tags : "${chave}=${valor}"])
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = "10254"
    type  = "string"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = "true"
    type  = "string"
  }

  depends_on = [kubernetes_namespace.ingress_nginx]
}
