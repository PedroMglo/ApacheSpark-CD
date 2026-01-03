FROM mcr.microsoft.com/devcontainers/python:3.11 AS base

# System deps
RUN apt-get update && apt-get install -y \
    default-jdk \
    curl \
    gnupg \
    ca-certificates \
    unzip \
    git-lfs \
 && git lfs install \
 && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV PATH=$JAVA_HOME/bin:$PATH

# Copiar apenas requirements.txt para cache eficaz
WORKDIR /tmp
COPY requirements.txt .
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/python -m pip install --upgrade pip && \
    /opt/venv/bin/pip install -r requirements.txt

# Copiar código do projeto (mas não reinstalar)
FROM mcr.microsoft.com/devcontainers/python:3.11
COPY --from=base /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/venv"

# Reinstalar apenas system deps (rápido)
RUN apt-get update && apt-get install -y default-jdk git-lfs && git lfs install && rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces/ApacheSpark-CD
#gvgvgvgvg