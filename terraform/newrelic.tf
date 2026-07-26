# AIOps: deteccao de anomalias (Applied Intelligence) sobre a telemetria OTLP
# que o otel-collector ja envia para o New Relic.
# Os recursos so sao criados quando as credenciais estao preenchidas no tfvars.

provider "newrelic" {
  account_id = var.newrelic_account_id
  api_key    = var.newrelic_api_key
  region     = "US"
}

resource "newrelic_alert_policy" "aiops" {
  count = var.newrelic_api_key != "" ? 1 : 0
  name  = "solidarytech-aiops"
}

# Baseline: o New Relic aprende o comportamento normal do sinal e alerta
# quando o valor foge do previsto, sem threshold fixo.
resource "newrelic_nrql_alert_condition" "latencia_anomala" {
  count              = var.newrelic_api_key != "" ? 1 : 0
  policy_id          = newrelic_alert_policy.aiops[0].id
  name               = "Latencia anomala no donation-service"
  type               = "baseline"
  baseline_direction = "upper_only"

  nrql {
    query = "SELECT average(duration.ms) FROM Span WHERE service.name = 'donation-service' AND span.kind = 'server'"
  }

  critical {
    operator              = "above"
    threshold             = 3
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 120
}

resource "newrelic_nrql_alert_condition" "erros_anomalos" {
  count              = var.newrelic_api_key != "" ? 1 : 0
  policy_id          = newrelic_alert_policy.aiops[0].id
  name               = "Taxa de erros anomala no donation-service"
  type               = "baseline"
  baseline_direction = "upper_only"

  nrql {
    query = "SELECT percentage(count(*), WHERE otel.status_code = 'ERROR') FROM Span WHERE service.name = 'donation-service' AND span.kind = 'server'"
  }

  critical {
    operator              = "above"
    threshold             = 3
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 120
}
