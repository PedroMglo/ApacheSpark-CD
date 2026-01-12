# .devcontainer/Dockerfile
# Devcontainer for studying Apache Spark 4.x with Python 3.12 (Ubuntu 24.04)

FROM mcr.microsoft.com/devcontainers/base:1.2.0-ubuntu-24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG SPARK_VERSION=4.0.1
ARG SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-hadoop3
ARG GIT_COMMIT=""
ARG BUILD_DATE=""

# ---- OS deps ----
RUN set -eux; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
        git-lfs \
        postgresql-client \
        python3 \
        python3-pip \
        python3-venv \
        python-is-python3 \
        openjdk-17-jre-headless \
    ; \
    git lfs install; \
    apt-get -y autoremove --purge; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# ---- Java ----
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# ---- Apache Spark (tarball) ----
RUN set -eux; \
    SPARK_TGZ_URL="https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz"; \
    mkdir -p /opt; \
    curl -fL "${SPARK_TGZ_URL}" -o /tmp/spark.tgz; \
    tar -xzf /tmp/spark.tgz -C /opt; \
    ln -s "/opt/${SPARK_PACKAGE}" /opt/spark; \
    rm -f /tmp/spark.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH="${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

# ---- GitHub CLI (gh) ----
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

# ---- Python deps via venv (PEP 668 friendly) ----
COPY .devcontainer/requirements.txt /tmp/requirements.txt

RUN set -eux; \
    python -m venv /opt/venv; \
    /opt/venv/bin/python -m pip install --no-cache-dir --upgrade pip setuptools wheel; \
    /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt; \
    /opt/venv/bin/python -m pip check; \
    chown -R vscode:vscode /opt/venv

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# Helpful defaults for Spark in containers (bind UI to all interfaces)
ENV SPARK_LOCAL_IP=0.0.0.0
ENV SPARK_DRIVER_BIND_ADDRESS=0.0.0.0

USER vscode
WORKDIR /workspaces/ApacheSpark-CD

LABEL org.opencontainers.image.revision=$GIT_COMMIT
LABEL org.opencontainers.image.created=$BUILD_DATE

CMD ["sleep", "infinity"]
