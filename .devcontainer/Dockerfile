FROM mcr.microsoft.com/devcontainers/python:3.11

# System deps
RUN apt-get update && \
    apt-get install -y \
      default-jdk \
      curl \
      gnupg \
      ca-certificates \
      unzip \
      git-lfs \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

# Java
ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV PATH=$JAVA_HOME/bin:$PATH

# GitHub CLI (gh)
RUN type gh >/dev/null 2>&1 || ( \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/* )
