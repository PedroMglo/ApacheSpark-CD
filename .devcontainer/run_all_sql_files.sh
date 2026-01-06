#!/usr/bin/env bash
set -euo pipefail

# 1. Configurações de Conexão
DB_HOST="${POSTGRES_HOST:-db}"
DB_USER="${POSTGRES_USER:-postgres}"

# --- A CORREÇÃO MÁGICA ESTÁ AQUI ---
# O psql só lê a password se a variável se chamar PGPASSWORD
export PGPASSWORD="${POSTGRES_PASSWORD:-postgres_password}"
# -----------------------------------

echo "A conectar ao Postgres em: $DB_HOST como $DB_USER"

# 2. Aguarda o Postgres estar pronto
until pg_isready -h "$DB_HOST" -U "$DB_USER" -d postgres >/dev/null 2>&1; do
  echo "Aguardando Postgres..."
  sleep 1
done

echo "Postgres está pronto! A iniciar scripts..."

# 3. Recria as bases de dados
psql -h "$DB_HOST" -U "$DB_USER" -d "postgres" <<EOF
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname IN ('retail_db','hr_db') AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS retail_db;
CREATE DATABASE retail_db;

DROP DATABASE IF EXISTS hr_db;
CREATE DATABASE hr_db;
EOF

# 4. Executa scripts na retail_db
echo "A correr create_db_tables_pg.sql..."
psql -h "$DB_HOST" -U "$DB_USER" -d "retail_db" -f /workspaces/ApacheSpark-CD/data/retail_db/create_db_tables_pg.sql

# echo "A correr create_db.sql..."
# psql -h "$DB_HOST" -U "$DB_USER" -d "retail_db" -f /workspaces/ApacheSpark-CD/data/retail_db/create_db.sql

echo "Concluído com sucesso! ✅"
# # 3) Executa scripts na hr_db
# # (Se este ficheiro não existir, comenta esta parte ou o script vai falhar)
# psql -h "$DB_HOST" -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "hr_db" \
#   -f /workspaces/ApacheSpark-CD/data/hr/hr_mysql.sql