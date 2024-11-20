# Use an official Ubuntu base image
FROM ubuntu:20.04

# Fix for pipe operations: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    TZ="Asia/Dhaka" \
    DEBIAN_FRONTEND="noninteractive" \
    RESOURCES_PATH="/resources" \
    PIPENV_VENV_IN_PROJECT=true \
    PYTHONUNBUFFERED=true \
    BETTER_EXCEPTIONS=1 \
    PYENV_ROOT="/resources/.pyenv" \
    PATH="/resources/.pyenv/shims:/resources/.pyenv/bin:$PATH"

# Update system and configure locales
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales tzdata \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    && ln -fs /usr/share/zoneinfo/Asia/Dhaka /etc/localtime \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a resources folder
RUN mkdir -p "$RESOURCES_PATH" && chmod a+rwx "$RESOURCES_PATH"

# Install essential packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        wget \
        gnupg2 \
        git \
        jq \
        software-properties-common \
        build-essential \
        libbz2-dev \
        libssl-dev \
        libreadline-dev \
        libsqlite3-dev \
        libffi-dev \
        python3 \
        python3-pip \
        gcc \
        python3-dev \
        make \
        tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Tini for better container init
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v0.19.0/tini -o /tini \
    && chmod +x /tini

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python tools and libraries
RUN pip install --no-cache-dir \
        setuptools==58.* \
        wheel==0.* \
        flake8==3.* \
        pytest==6.* \
        twine==3.* \
        mypy==0.* \
        pytest-cov==3.* \
        black==21.10b0 \
        pydocstyle==6.* \
        isort==5.* \
        docker==5.* \
        nox==2021.10.* \
        pipenv==2021.11.* \
        better-exceptions==0.* \
        cryptography>=3.2.1 \
        lxml>=4.6.2

# Install Pyenv
RUN git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g yarn@1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Markdown lint tools
RUN npm install -g markdownlint@^0.24.0 markdownlint-cli@^0.29.0

# Workaround for SSH in GitHub Actions
RUN mkdir -p /github/home/.ssh \
    && touch /github/home/.ssh/config \
    && chmod 700 /github/home/.ssh \
    && ln -s /github/home/.ssh /root/.ssh

# Install custom buildkit
RUN curl -fsSL https://github.com/khulnasoft/ml-buildkit/archive/refs/heads/main.zip -o "$RESOURCES_PATH/ml-buildkit.tar.gz" \
    && pip install "$RESOURCES_PATH/ml-buildkit.tar.gz"

# Install Hadolint
RUN curl -fsSL https://github.com/hadolint/hadolint/releases/download/v2.8.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint

# Install Trivy vulnerability scanner
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin

# Add entrypoint script
COPY ./resources/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/tini", "-g", "--", "/entrypoint.sh"]
