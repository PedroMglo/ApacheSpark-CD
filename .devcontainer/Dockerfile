# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

USER root

# Dependências de sistema (minimizadas)
RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
        openjdk-21-jre-headless \
        ca-certificates \
        curl \
        unzip \
        git-lfs \
        postgresql-client \
    ; \
    git lfs install; \
    apt-get -y autoremove --purge; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Java
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# GitHub CLI (gh) - instala via repo oficial
RUN set -eux; \
    install -m 0755 -d /usr/share/keyrings; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg; \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends gh; \
    apt-get -y autoremove --purge; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Python deps baked (melhor cache: copia só o requirements antes do resto do repo)
COPY .devcontainer/requirements.txt /tmp/requirements.txt

USER vscode
ENV PATH="/home/vscode/.local/bin:${PATH}"

RUN set -eux; \
    python -m pip install --no-cache-dir --upgrade pip setuptools wheel; \
    pip install --no-cache-dir -r /tmp/requirements.txt; \
    python -m pip check

WORKDIR /workspaces/ApacheSpark-CD

# --- METADADOS ---
ARG GIT_COMMIT=""
ARG BUILD_DATE=""
LABEL org.opencontainers.image.revision=$GIT_COMMIT
LABEL org.opencontainers.image.created=$BUILD_DATE

CMD ["sleep", "infinity"]
