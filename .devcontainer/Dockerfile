# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:bookworm

USER root

RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        python-is-python3 \
        openjdk-17-jre-headless \
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

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# GitHub CLI (gh)
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

# --- Python deps via venv (PEP 668 friendly) ---
COPY .devcontainer/requirements.txt /tmp/requirements.txt

RUN set -eux; \
    python -m venv /opt/venv; \
    /opt/venv/bin/python -m pip install --no-cache-dir --upgrade pip setuptools wheel; \
    /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt; \
    /opt/venv/bin/python -m pip check; \
    chown -R vscode:vscode /opt/venv

# Faz o venv ser o python/pip "default" para o user vscode
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

USER vscode
WORKDIR /workspaces/ApacheSpark-CD

ARG GIT_COMMIT=""
ARG BUILD_DATE=""
LABEL org.opencontainers.image.revision=$GIT_COMMIT
LABEL org.opencontainers.image.created=$BUILD_DATE

CMD ["sleep", "infinity"]
