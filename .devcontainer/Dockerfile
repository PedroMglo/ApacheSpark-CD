# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG SPARK_VERSION=4.0.1
ARG SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-hadoop3
ARG GIT_COMMIT=""
ARG BUILD_DATE=""

# ---- OS deps (cache-friendly; no apt upgrade) ----
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    set -eux; \
    apt-get update; \
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
        jq \
    ; \
    git lfs install; \
    rm -rf /var/lib/apt/lists/*

# ---- Java ----
# Note: on amd64 this path matches; on arm64 it differs, but it's fine because we only need java on PATH.
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# ---- Apache Spark (tarball) ----
RUN set -eux; \
    SPARK_TGZ_URL="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz"; \
    mkdir -p /opt; \
    curl -fL --retry 5 --retry-delay 2 "${SPARK_TGZ_URL}" -o /tmp/spark.tgz; \
    tar -xzf /tmp/spark.tgz -C /opt; \
    ln -s "/opt/${SPARK_PACKAGE}" /opt/spark; \
    rm -f /tmp/spark.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH="${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

# Expose Spark's bundled PySpark + Py4J to Python (no pip pyspark needed)
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-*-src.zip"

# ---- Python deps via venv (cache-friendly) ----
COPY .devcontainer/requirements.txt /tmp/requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
    set -eux; \
    python -m venv /opt/venv; \
    /opt/venv/bin/python -m pip install --upgrade pip wheel "setuptools>=78.1.1"; \
    # Install delta-spark without pulling pyspark (we use Spark-bundled PySpark)
    /opt/venv/bin/pip install --no-deps delta-spark==4.0.1; \
    /opt/venv/bin/pip install -r /tmp/requirements.txt; \
    /opt/venv/bin/python -m pip check; \
    chown -R vscode:vscode /opt/venv

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

ENV SPARK_LOCAL_IP=0.0.0.0
ENV SPARK_DRIVER_BIND_ADDRESS=0.0.0.0

USER vscode
WORKDIR /workspaces/ApacheSpark-CD

LABEL org.opencontainers.image.revision=$GIT_COMMIT
LABEL org.opencontainers.image.created=$BUILD_DATE

CMD ["sleep", "infinity"]
