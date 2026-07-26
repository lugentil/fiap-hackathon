# donation-service (Go)

Serviço de processamento das doações da SolidaryTech. É o **caminho crítico (Hot Path)** da plataforma: registra a doação no PostgreSQL e publica um evento na fila SQS para o `report-service` consumir.

* **Linguagem:** Go
* **Banco de Dados:** PostgreSQL
* **Mensageria:** AWS SQS
* **Autenticação:** chave de API validada no `auth-service`

## Como rodar localmente

1.  **Clone o repositório** e entre na pasta `donation-service`.

2.  **Configure o banco:**
    * Crie um banco de dados no seu PostgreSQL (ex: `donation_db`).
    * Execute o script `db/init.sql` para criar a tabela `donations`:
        ```bash
        psql -U seu_usuario -d donation_db -f db/init.sql
        ```

3.  **Configure as variáveis de ambiente:**
    Crie um arquivo chamado `.env` na raiz desta pasta com o seguinte conteúdo:
    ```.env
    # String de conexão do seu banco de dados PostgreSQL
    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/donation_db"

    # Porta que este serviço (donation-service) irá rodar
    PORT="8004"

    # URL do auth-service (que deve estar rodando na porta 8001)
    AUTH_SERVICE_URL="http://localhost:8001"

    # --- Configuração da AWS (opcional para rodar local) ---
    # Cole a URL da fila SQS criada na AWS
    AWS_SQS_URL="SUA_URL_DA_FILA_SQS"

    # Região da sua fila SQS
    AWS_REGION="us-east-1"
    ```

4.  **Instale as dependências e rode:**
    ```bash
    go mod tidy
    go run .
    ```

## Como testar

**1. Crie uma chave de API no auth-service (requer a MASTER_KEY):**
```bash
curl -X POST http://localhost:8001/admin/keys \
-H "Content-Type: application/json" \
-H "Authorization: Bearer admin-secreto-123" \
-d '{"name": "admin-para-donation-service"}'
```

**2. Registre uma doação (use a chave criada acima):**
```bash
curl -X POST http://localhost:8004/donations \
-H "Content-Type: application/json" \
-H "Authorization: Bearer SUA_CHAVE_API" \
-d '{"ngo_id": 1, "amount": 50.00, "donor_name": "Maria Silva"}'
```

**3. Liste as doações:**
```bash
curl http://localhost:8004/donations \
-H "Authorization: Bearer SUA_CHAVE_API"
```

