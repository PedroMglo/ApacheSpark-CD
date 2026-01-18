# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG SPARK_VERSION=4.0.1
ARG SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-hadoop3
ARG DELTA_VERSION=4.0.1
ARG GIT_COMMIT=""
ARG BUILD_DATE=""

# ---- OS deps (cache-friendly) ----
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache-${TARGETPLATFORM} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib-${TARGETPLATFORM} \
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

# ---- Apache Spark (tarball) ----
# Use archive.apache.org for reproducible builds.
RUN set -eux; \
    SPARK_TGZ_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz"; \
    mkdir -p /opt; \
    curl -fL --retry 5 --retry-delay 2 "${SPARK_TGZ_URL}" -o /tmp/spark.tgz; \
    tar -xzf /tmp/spark.tgz -C /opt; \
    ln -s "/opt/${SPARK_PACKAGE}" /opt/spark; \
    rm -f /tmp/spark.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH="${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

# ---- Make Py4J zip path stable (avoid wildcards in ENV) ----
RUN set -eux; \
    PY4J_ZIP="$(ls -1 ${SPARK_HOME}/python/lib/py4j-*-src.zip | head -n 1)"; \
    ln -sf "${PY4J_ZIP}" "${SPARK_HOME}/python/lib/py4j.zip"

# Expose Spark's bundled PySpark + Py4J to Python (no pip pyspark needed)
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib:${SPARK_HOME}/python/lib/py4j.zip"

# Ensure PySpark uses venv python
ENV PYSPARK_PYTHON=/opt/venv/bin/python
ENV PYSPARK_DRIVER_PYTHON=/opt/venv/bin/python

# Spark networking defaults for containers
ENV SPARK_LOCAL_IP=0.0.0.0
ENV SPARK_DRIVER_BIND_ADDRESS=0.0.0.0

# ---- Spark defaults (Delta enabled) ----
RUN set -eux; \
    mkdir -p "${SPARK_HOME}/conf" /opt/spark/ivy; \
    cat > "${SPARK_HOME}/conf/spark-defaults.conf" <<EOF
spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension
spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog
spark.jars.packages=io.delta:delta-spark_2.13:${DELTA_VERSION}
spark.jars.ivy=/opt/spark/ivy
EOF

# ---- Python deps via venv (cache-friendly) ----
COPY .devcontainer/requirements.txt /tmp/requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
    set -eux; \
    python -m venv /opt/venv; \
    /opt/venv/bin/python -m pip install --upgrade pip wheel "setuptools>=78.1.1"; \
    \
    # delta-spark without pulling pyspark; add the missing deps explicitly so pip check passes
    /opt/venv/bin/pip install --no-deps "delta-spark==${DELTA_VERSION}"; \
    /opt/venv/bin/pip install "importlib-metadata>=6" "py4j>=0.10.9"; \
    \
    /opt/venv/bin/pip install -r /tmp/requirements.txt; \
    /opt/venv/bin/python -m pip check

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# ---- Optional: pre-fetch Delta jars during build (avoid runtime downloads) ----
RUN set -eux; \
    mkdir -p /opt/spark/ivy; \
    ${SPARK_HOME}/bin/spark-submit \
      --conf spark.jars.ivy=/opt/spark/ivy \
      --class org.apache.spark.examples.SparkPi \
      ${SPARK_HOME}/examples/jars/spark-examples_2.13-${SPARK_VERSION}.jar \
      1 >/dev/null

# Permissions for the dev user
RUN set -eux; \
    chown -R vscode:vscode /opt/venv /opt/spark/ivy

USER vscode
WORKDIR /workspaces/ApacheSpark-CD

LABEL org.opencontainers.image.revision=$GIT_COMMIT
LABEL org.opencontainers.image.created=$BUILD_DATE

CMD ["sleep", "infinity"]
