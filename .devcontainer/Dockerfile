FROM mcr.microsoft.com/devcontainers/python:3.11

# Dependências de sistema
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    curl \
    ca-certificates \
    unzip \
    git-lfs \
    postgresql-client \
 && git lfs install \
 && rm -rf /var/lib/apt/lists/*

# Java
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python deps "baked" na imagem (Spark 4.x + Delta 4.x)
# Nota: pyspark==4.0.1 (Spark 4.0.1) + delta-spark==4.0.1 (Delta Lake 4.0.1)
COPY requirements.txt /tmp/requirements.txt
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt


# --- METADADOS (rastreabilidade) ---
ARG GIT_COMMIT=""
ARG BUILD_DATE=""
LABEL org.opencontainers.image.revision=$GIT_COMMIT
LABEL org.opencontainers.image.created=$BUILD_DATE
# --- FIM METADADOS ---
