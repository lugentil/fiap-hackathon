# volunteer-service (Python)

Serviço de cadastro e inscrição de voluntários interessados em apoiar as ONGs parceiras da SolidaryTech.

* **Linguagem:** Python (Flask)
* **Banco de Dados:** AWS DynamoDB
* **Autenticação:** chave de API validada no `auth-service`

## Como rodar localmente

1.  **Clone o repositório** e entre na pasta `volunteer-service`.

2.  **Configure o DynamoDB:**
    Crie uma tabela no AWS DynamoDB:
    * Nome da tabela: `SolidaryTechVolunteers`
    * Partition Key: `volunteer_id` (String)

3.  **Configure as variáveis de ambiente:**
    Crie um arquivo chamado `.env` na raiz desta pasta (`volunteer-service/`) com o seguinte conteúdo. **Garanta que suas credenciais da AWS também estejam configuradas no seu ambiente.**
    ```.env
    # Porta que este serviço (volunteer-service) irá rodar
    PORT="8003"

    # URL do auth-service (que deve estar rodando na porta 8001)
    AUTH_SERVICE_URL="http://localhost:8001"

    # Nome da tabela DynamoDB que você criou
    AWS_DYNAMODB_TABLE="SolidaryTechVolunteers"

    # Região da sua tabela DynamoDB
    AWS_REGION="us-east-1"
    ```

4.  **Instale as dependências e rode:**
    ```bash
    pip install -r requirements.txt
    python app.py
    ```

## Como testar

**1. Crie uma chave de API no auth-service (requer a MASTER_KEY):**
```bash
curl -X POST http://localhost:8001/admin/keys \
-H "Content-Type: application/json" \
-H "Authorization: Bearer admin-secreto-123" \
-d '{"name": "admin-para-volunteer-service"}'
```

**2. Cadastre um voluntário (use a chave criada acima):**
```bash
curl -X POST http://localhost:8003/volunteers \
-H "Content-Type: application/json" \
-H "Authorization: Bearer SUA_CHAVE_API" \
-d '{"name": "João Souza", "email": "joao@email.com", "ngo_id": 1}'
```

**3. Liste os voluntários de uma ONG:**
```bash
curl http://localhost:8003/volunteers/1 \
-H "Authorization: Bearer SUA_CHAVE_API"
```

