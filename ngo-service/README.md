# ngo-service (Python)

Serviço de cadastro e gestão das ONGs parceiras da SolidaryTech.

* **Linguagem:** Python (Flask)
* **Banco de Dados:** PostgreSQL
* **Autenticação:** chave de API validada no `auth-service`

## Como rodar localmente

1.  **Clone o repositório** e entre na pasta `ngo-service`.

2.  **Configure o banco:**
    * Crie um banco de dados no seu PostgreSQL (ex: `ngo_db`).
    * Execute o script `db/init.sql` para criar a tabela `ngos`:
        ```bash
        psql -U seu_usuario -d ngo_db -f db/init.sql
        ```

3.  **Configure as variáveis de ambiente:**
    Crie um arquivo chamado `.env` na raiz desta pasta (`ngo-service/`) com o seguinte conteúdo:
    ```.env
    # String de conexão do seu banco de dados PostgreSQL
    DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/ngo_db"

    # Porta que este serviço (ngo-service) irá rodar
    PORT="8002"

    # URL do auth-service (que deve estar rodando na porta 8001)
    AUTH_SERVICE_URL="http://localhost:8001"
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
-d '{"name": "admin-para-ngo-service"}'
```

**2. Cadastre uma ONG (use a chave criada acima):**
```bash
curl -X POST http://localhost:8002/ngos \
-H "Content-Type: application/json" \
-H "Authorization: Bearer SUA_CHAVE_API" \
-d '{"name": "Anjos de Patas", "email": "contato@anjosdepatas.org", "cause": "Proteção Animal", "city": "Osasco"}'
```

**3. Liste as ONGs cadastradas:**
```bash
curl http://localhost:8002/ngos \
-H "Authorization: Bearer SUA_CHAVE_API"
```
