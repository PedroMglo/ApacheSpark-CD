FROM mcr.microsoft.com/devcontainers/python:3.11

# Dependências de sistema
# Inclui o postgresql-client para permitir que o script de inicialização corra comandos psql
RUN apt-get update && apt-get install -y \
    default-jdk \
    curl \
    ca-certificates \
    unzip \
    git-lfs \
    postgresql-client \
 && git lfs install \
 && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV PATH="$JAVA_HOME/bin:$PATH"