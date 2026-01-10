# ApacheSpark-CD — Ambiente de Estudo de Apache Spark (PySpark)

Este repositório foi criado como um **laboratório prático** para estudar **Apache Spark** (com foco em **PySpark**) num ambiente reproduzível, fácil de arrancar e consistente entre máquinas.

O objetivo é permitir:
- aprender Spark “a sério” (DataFrames, SQL, joins, window functions, otimização, partições, etc.);
- praticar ingestão e transformação de dados em batches;
- integrar Spark com uma base de dados relacional (**PostgreSQL**);
- trabalhar num ambiente padronizado via **Dev Containers / GitHub Codespaces**.

---

## ✨ O que vais encontrar aqui

- **Ambiente Docker/Devcontainer** para desenvolvimento rápido e reproduzível
- **PostgreSQL** como serviço (via Docker Compose)
- Scripts para:
  - preparar dependências Python e ambiente (`bootstrap.sh`)
  - obter datasets (`get_data.sh`)
  - inicializar/carregar SQL no Postgres (`run_all_sql_files.sh`)
- Código PySpark para ETL/transformações e escrita de outputs (ex.: Parquet)

> Nota: a estrutura exata pode variar, mas o repositório está organizado para ser simples de executar e iterar.

---

## 🧱 Pré-requisitos

### Opção A — Recomendado (mais simples)
- **GitHub Codespaces** (ou VS Code com Dev Containers)

### Opção B — Local
- Docker + Docker Compose
- VS Code + extensão *Dev Containers* (opcional, mas recomendado)

---

## 🚀 Quickstart (Codespaces / Devcontainer)

1. Abre o repositório no GitHub
2. Clica em **Code → Codespaces → Create codespace**
3. O ambiente vai:
   - construir os containers (app + db)
   - configurar dependências e ambiente Python
   - (opcional) obter dados e preparar SQL dependendo dos scripts configurados

Dentro do Codespace, deves ter:
- workspace em: `/workspaces/ApacheSpark-CD`
- Python/venv em: `/workspaces/ApacheSpark-CD/.venv`
- Postgres acessível pelo hostname: `db`

---

## 🐘 PostgreSQL (via Docker Compose)

O serviço do Postgres é levantado pelo Docker Compose e fica disponível dentro do container `app` com:

- Host: `db`
- User: `postgres`
- Password: `postgres_password` (podes mudar)
- Porta: `5432`

> Se o repositório for público/partilhado, recomenda-se mover passwords para **Codespaces Secrets**.

---

## 🧪 Fluxo típico de estudo

### 1) Preparar ambiente Python
```bash
bash scripts/bootstrap.sh
````

### 2) Obter dados (se aplicável)

```bash
bash scripts/get_data.sh
```

### 3) Inicializar Postgres com SQL (se aplicável)

```bash
bash scripts/run_all_sql_files.sh
```

### 4) Correr um job Spark (exemplo)

> Ajusta o caminho conforme a estrutura do repositório:

```bash
python jobs/exemplo_job.py
# ou
spark-submit jobs/exemplo_job.py
```

---

## 📚 Tópicos que este repositório pretende cobrir

### Spark / PySpark

* DataFrames: `select`, `filter`, `withColumn`, `groupBy`
* Joins: broadcast vs shuffle
* Window functions
* Leitura e escrita: CSV/Parquet
* Partições, `repartition`, `coalesce`
* Persistência/caching
* Debug: DAG, stages, tasks (Spark UI)

### Integração com Postgres

* leitura via JDBC
* escrita via JDBC
* normalização de schemas
* carga incremental (quando aplicável)

### Boas práticas de engenharia

* ambiente reprodutível (devcontainer)
* scripts idempotentes (evitar downloads/cargas repetidas)
* organização de jobs e outputs
* logging e observabilidade

---

## 🗂️ Estrutura típica do repositório

> Exemplo (pode variar):

```
.
├─ .devcontainer/
│  └─ devcontainer.json
├─ docker-compose.yml
├─ scripts/
│  ├─ bootstrap.sh
│  ├─ get_data.sh
│  └─ run_all_sql_files.sh
├─ jobs/
│  └─ ...
├─ data/
│  └─ ...
└─ README.md
```

---

## 🔧 Dicas para performance em Codespaces

* Considera **Prebuilds** para acelerar a criação do ambiente
* Evita downloads pesados em `postCreateCommand` (melhor em `postStartCommand`)
* Torna `get_data.sh` e scripts SQL **idempotentes** (não repetirem trabalho)

---

## 🤝 Contribuição

Este repositório é um ambiente de estudo. Sugestões e melhorias são bem-vindas:

* issues com bugs/ideias
* PRs com novos jobs, datasets, exercícios e otimizações



```bash
cd /workspaces/ApacheSpark-CD
tree -L 3
````
