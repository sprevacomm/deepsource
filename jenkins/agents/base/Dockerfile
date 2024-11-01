FROM jenkins/inbound-agent:latest-alpine-jdk17

ARG GH_VERSION=2.40.1
ARG K8S_VERSION=1.28.4
ARG GRYPE_VERSION=v0.73.3
ARG SONAR_SCANNER_VERSION=6.1.0.4477-linux-x64

USER root

#COPY zscaler_root_ca.pem /usr/local/share/ca-certificates/zscaler.crt
# COPY sonar-scanner.properties .
#RUN update-ca-certificates

RUN apk add --no-cache \
    aws-cli \
    bash \
    coreutils \
    curl \
    gcc \
    git \
    github-cli \
    helm \
    firefox \
    libffi-dev \
    make \
    musl-dev \
    nodejs \
    npm \
    openssl-dev \
    py3-pip \
    python3-dev \
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
RUN echo 'base' > /container_type

# Install sonar-scanner

RUN curl -fSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip -o /opt/sonar-scanner.zip && \
    unzip /opt/sonar-scanner.zip -d /opt && \
    rm /opt/sonar-scanner.zip && \
    ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner /usr/bin/sonar-scanner && \
    rm /opt/sonar-scanner-${SONAR_SCANNER_VERSION}/jre/bin/java && \
    ln -s /opt/java/openjdk/bin/java /opt/sonar-scanner-${SONAR_SCANNER_VERSION}/jre/bin/java 
    # cp sonar-scanner.properties /opt/sonar-scanner-${SONAR_SCANNER_VERSION}/conf/ && \
    # sonar-scanner -v
