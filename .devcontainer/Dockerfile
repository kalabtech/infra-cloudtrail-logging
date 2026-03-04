# Use Ubuntu base as development environment standard
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Disable interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base tools, AWS CLI, and Terraform
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    git \
    && rm -rf /var/lib/apt/lists/*

# 1. Install AWS CLI v2
RUN arch=$(uname -m) && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws

# 2. tfenv: Installation and setup for vscode user
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git /home/vscode/.tfenv && \
    chown -R vscode:vscode /home/vscode/.tfenv && \
    ln -s /home/vscode/.tfenv/bin/* /usr/local/bin/

# Restore interactive mode
ENV DEBIAN_FRONTEND=dialog
