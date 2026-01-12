# 0) Pré-requisitos (uma vez)

Precisas de:

- **Git**
- **Docker Desktop** (Windows/Mac) ou **Docker Engine + Docker Compose v2** (Linux)
- **VS Code** + extensão **Dev Containers**

### Que terminal usar e como abrir

Escolhe um destes (o que for mais cómodo):

**Opção A — Terminal do sistema**

- **Windows**: PowerShell (Start → “PowerShell”) ou Windows Terminal
- **macOS**: Terminal (Applications → Utilities → Terminal)
- **Linux**: Terminal da tua distro

**Opção B — Terminal dentro do VS Code**

1. Abre o VS Code
2. Menu **Terminal → New Terminal** (ou `Ctrl+` ``)

> Para começar (clonar repo, docker login, etc.), a Opção A ou B dá igual.

---

## 1) Clonar o repositório (Git)

No terminal (PowerShell/Terminal/VS Code Terminal), vai para a pasta onde queres ter o projeto e clona.

```bash
cd ~/projects
git clone <URL_DO_TEU_REPO> ApacheSpark-CD
cd ApacheSpark-CD
```

**O que faz:**

- `cd`: muda de diretório
- `git clone`: descarrega o repositório para a tua máquina
- `cd ApacheSpark-CD`: entra na pasta do projeto

> Se já tens a pasta mas queres garantir que está atualizada:

```bash
git pull
```

Isto traz as últimas alterações do remoto.

---

## 2) (Opcional) Criar o `.env` local

O teu `docker-compose.yml` usa `env_file: .env`. Tens de ter um `.env` na raiz de `.devcontainer` **ou** no path que o compose está a ler (no teu caso, dentro de `.devcontainer`, ele referencia `.env` relativo a `.devcontainer`).

Confirma onde está o `.env` esperado:

- no teu compose, tens `env_file: - .env` dentro de `.devcontainer/docker-compose.yml`
- isso normalmente significa **`.devcontainer/.env`**

### Criar `.devcontainer/.env`

No terminal na raiz do repo:

```bash
mkdir -p .devcontainer
```

Cria o ficheiro `.devcontainer/.env` (podes usar editor do VS Code ou comando). Exemplo rápido em Linux/macOS:

```bash
cat > .devcontainer/.env << 'EOF'
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=sparkdb
EOF
```

No **PowerShell (Windows)**:

```powershell
@"
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=sparkdb
"@ | Out-File -Encoding utf8 .devcontainer\.env
```

**O que faz:**

- Garante que quando o compose sobe o Postgres, ele tem credenciais.
- Mesmo que não vás “testar” Postgres, o serviço precisa arrancar para o `depends_on` do container principal passar no healthcheck.

---

## 3) Construir a imagem localmente (sem Docker Hub)

Como disseste que **ainda não tens a imagem no PC**, tens dois caminhos:

### Caminho 1 (recomendado): build via Docker Compose

Isto usa o teu `docker-compose.yml` e constrói a imagem definida no `build:`.

Na raiz do repo (onde está a pasta `.devcontainer`), corre:

```bash
docker compose -f .devcontainer/docker-compose.yml build
```

**O que faz:**

- Lê o compose
- Vê o serviço `apache_spark` com `build:`
- Executa o Dockerfile `.devcontainer/Dockerfile`
- No fim ficas com uma imagem local com o nome/tag do compose (`pmglok/spark:active`)

> Dica: se quiseres ver as imagens no fim:

```bash
docker images | grep pmglok/spark
```

### Caminho 2: build direto com Docker

Se quiseres “à mão”, sem compose:

```bash
docker build \
  -f .devcontainer/Dockerfile \
  -t pmglok/spark:active \
  .
```

**O que faz:**

- Compila o Dockerfile e cria a imagem `pmglok/spark:active`.

---

## 4) Subir os containers (só verificar que arrancam)

Agora sobe os serviços definidos no compose:

```bash
docker compose -f .devcontainer/docker-compose.yml up -d
```

**O que faz:**

- `up`: cria e inicia containers
- `-d`: “detached” (fica em background)

### Verificar que estão “up”

```bash
docker compose -f .devcontainer/docker-compose.yml ps
```

**O que faz:**

- Mostra os serviços e o estado (Up/healthy, etc.)

### Ver logs (se precisares)

Se algum serviço não ficar “Up”, vê logs:

```bash
docker compose -f .devcontainer/docker-compose.yml logs -f
```

**O que faz:**

- Mostra logs em tempo real (`-f`)

> Nota: como o teu `apache_spark` faz `sleep infinity`, ele deve ficar “Up” facilmente. O Postgres é o que pode demorar uns segundos por causa do `healthcheck`.

---

## 5) Aceder ao terminal “dentro do container”

Tens duas formas (as duas são úteis):

### Opção A — `docker exec` (terminal do sistema)

Primeiro descobre o nome do container do serviço `apache_spark`:

```bash
docker compose -f .devcontainer/docker-compose.yml ps
```

Vais ver um nome tipo `apachesparkcd-apache_spark-1` (depende da pasta/projeto).

Entra com:

```bash
docker exec -it <NOME_DO_CONTAINER> bash
```

**O que faz:**

- `exec`: executa um comando dentro do container
- `-it`: modo interativo com terminal
- `bash`: abre uma shell

Para sair:

```bash
exit
```

### Opção B — Terminal do Dev Container no VS Code (mais “bonito”)

1. Abre o VS Code na pasta do projeto:

   ```bash
   code .
   ```

2. No VS Code:

   - `Ctrl+Shift+P` (Command Palette)
   - escolhe **“Dev Containers: Reopen in Container”**

3. Quando abrir dentro do container:

   - Menu **Terminal → New Terminal**
   - Esse terminal já está **dentro do container** como `vscode`.

**O que isto faz:**

- O VS Code liga ao serviço `apache_spark` do compose
- Usa o `devcontainer.json`
- Monta o workspace e dá-te terminal interno

---

## 6) Parar e limpar (quando não precisares)

### Parar containers (mantém volumes)

```bash
docker compose -f .devcontainer/docker-compose.yml down
```

**O que faz:**

- Para e remove os containers e a network
- Mantém volumes (`pgdata`, `sparkdata`) por defeito

### Parar e apagar volumes (reset total)

```bash
docker compose -f .devcontainer/docker-compose.yml down -v
```

**O que faz:**

- Apaga também os volumes
- É “reset” do estado (dados do Postgres e `data/` do volume)

---

## 7) Fluxo Git básico (para ir evoluindo o projeto)

Na raiz do repo:

### Ver estado

```bash
git status
```

### Criar branch para mudanças

```bash
git checkout -b chore/improve-devcontainer
```

### Adicionar alterações

```bash
git add .
```

### Commit

```bash
git commit -m "Improve devcontainer for Spark 4.x"
```

### Enviar para o remoto

```bash
git push -u origin chore/improve-devcontainer
```

**O que faz:**

- Cria branch
- Prepara ficheiros
- Cria commit
- Publica no GitHub para abrir PR

---

## 8) (Opcional) Pull da imagem do Docker Hub (quando já existir lá)

Quando tiveres publicado `pmglok/spark:active` no Docker Hub e quiseres **evitar build local**, faz:

```bash
docker pull pmglok/spark:active
```

Depois sobe:

```bash
docker compose -f .devcontainer/docker-compose.yml up -d
```

> Se o compose tiver `build:` e quiseres forçar a usar só a imagem puxada, podes comentar `build:` ou usar `--no-build`.
