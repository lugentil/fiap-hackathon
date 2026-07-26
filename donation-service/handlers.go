package main

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"
)

func (a *App) healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if _, err := w.Write([]byte(`{"status":"ok","service":"donation-service"}`)); err != nil {
		logCtx(r.Context(), "Erro ao escrever resposta do health: %v", err)
	}
}

// requireAuth valida a chave de API no auth-service antes de liberar a rota
func (a *App) requireAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			http.Error(w, `{"error":"Authorization header obrigatório"}`, http.StatusUnauthorized)
			return
		}

		req, err := http.NewRequestWithContext(r.Context(), http.MethodGet, a.AuthServiceURL+"/validate", nil)
		if err != nil {
			http.Error(w, `{"error":"Erro interno"}`, http.StatusInternalServerError)
			return
		}
		req.Header.Set("Authorization", authHeader)

		resp, err := a.HttpClient.Do(req)
		if err != nil {
			logCtx(r.Context(), "Erro ao conectar com o auth-service: %v", err)
			http.Error(w, `{"error":"Serviço de autenticação indisponível"}`, http.StatusServiceUnavailable)
			return
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			http.Error(w, `{"error":"Chave de API inválida"}`, http.StatusUnauthorized)
			return
		}

		next(w, r)
	}
}

func (a *App) donationHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	ctx := r.Context()

	if r.Method == http.MethodPost {
		var d Donation
		if err := json.NewDecoder(r.Body).Decode(&d); err != nil {
			http.Error(w, `{"error":"Payload inválido"}`, http.StatusBadRequest)
			return
		}

		d.Status = "APPROVED" // Simulação de gateway de pagamento
		err := a.DB.QueryRowContext(ctx,
			"INSERT INTO donations (ngo_id, amount, donor_name, status) VALUES ($1, $2, $3, $4) RETURNING id, created_at",
			d.NgoID, d.Amount, d.DonorName, d.Status,
		).Scan(&d.ID, &d.CreatedAt)

		if err != nil {
			logCtx(ctx, "Erro ao salvar doação: %v", err)
			http.Error(w, `{"error":"Erro interno"}`, http.StatusInternalServerError)
			return
		}

		if a.SqsSvc != nil {
			// WithoutCancel: a goroutine sobrevive ao fim da requisicao, mas mantem o trace
			go a.sendNotificationEvent(context.WithoutCancel(ctx), d)
		}

		w.WriteHeader(http.StatusCreated)
		if err := json.NewEncoder(w).Encode(d); err != nil {
			logCtx(ctx, "Erro ao serializar doação: %v", err)
		}
		return
	}

	if r.Method == http.MethodGet {
		rows, err := a.DB.QueryContext(ctx, "SELECT id, ngo_id, amount, donor_name, status, created_at FROM donations ORDER BY id DESC")
		if err != nil {
			logCtx(ctx, "Erro ao buscar doações: %v", err)
			http.Error(w, `{"error":"Erro interno"}`, http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		donations := []Donation{}
		for rows.Next() {
			var d Donation
			if err := rows.Scan(&d.ID, &d.NgoID, &d.Amount, &d.DonorName, &d.Status, &d.CreatedAt); err != nil {
				logCtx(ctx, "Erro ao ler doação: %v", err)
				continue
			}
			donations = append(donations, d)
		}

		if err := json.NewEncoder(w).Encode(donations); err != nil {
			logCtx(ctx, "Erro ao serializar doações: %v", err)
		}
		return
	}

	http.Error(w, `{"error":"Método não permitido"}`, http.StatusMethodNotAllowed)
}

func (a *App) sendNotificationEvent(ctx context.Context, d Donation) {
	ctx, span := otel.Tracer("donation-service").Start(ctx, "publish donation event",
		trace.WithSpanKind(trace.SpanKindProducer))
	defer span.End()

	body, err := json.Marshal(d)
	if err != nil {
		logCtx(ctx, "Erro ao serializar evento SQS: %v", err)
		return
	}

	// injeta o traceparent nos atributos da mensagem para o report-service continuar o mesmo trace
	attrs := sqsAttrCarrier{}
	otel.GetTextMapPropagator().Inject(ctx, attrs)

	_, err = a.SqsSvc.SendMessage(&sqs.SendMessageInput{
		MessageBody:       aws.String(string(body)),
		QueueUrl:          aws.String(a.SqsQueueURL),
		MessageAttributes: attrs,
	})
	if err != nil {
		logCtx(ctx, "Falha ao despachar evento SQS: %v", err)
	}
}

// sqsAttrCarrier adapta os message attributes do SQS ao TextMapCarrier do OpenTelemetry
type sqsAttrCarrier map[string]*sqs.MessageAttributeValue

func (c sqsAttrCarrier) Get(key string) string {
	if v, ok := c[key]; ok && v.StringValue != nil {
		return *v.StringValue
	}
	return ""
}

func (c sqsAttrCarrier) Set(key, value string) {
	c[key] = &sqs.MessageAttributeValue{
		DataType:    aws.String("String"),
		StringValue: aws.String(value),
	}
}

func (c sqsAttrCarrier) Keys() []string {
	keys := make([]string, 0, len(c))
	for k := range c {
		keys = append(keys, k)
	}
	return keys
}
