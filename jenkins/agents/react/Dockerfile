FROM jenkins/inbound-agent:latest-alpine-jdk17

ARG GH_VERSION=2.40.1
ARG K8S_VERSION=1.28.4
ARG GRYPE_VERSION=v0.73.3
USER root

#COPY zscaler_root_ca.pem /usr/local/share/ca-certificates/zscaler.crt
#RUN update-ca-certificates

RUN apk add --no-cache \
    bash \
    coreutils \
    curl \
    gcc \
    git \
    github-cli \
    helm \
    libffi-dev \
    make \
    musl-dev \
    openssl-dev \
    ruby \
    ruby-dev \
    postgresql-dev \
    unzip \
    zip

# Install kubectl
RUN curl -kfSsL -o /usr/local/bin/kubectl "https://dl.k8s.io/v${K8S_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# Install Grype
RUN curl -fSsL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/bin "$GRYPE_VERSION"

# Install gh cli
RUN curl -fSsL -o gh.tar.gz "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" && \
    tar -xvf gh.tar.gz --strip-components=1 -C / && \
    rm -f gh.tar.gz

# Install bundler
RUN gem install bundler --conservative
RUN echo 'react' > /container_type
