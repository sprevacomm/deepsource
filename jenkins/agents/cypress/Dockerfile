FROM jenkins/inbound-agent:latest
#FROM jenkins/inbound-agent:latest-alpine-jdk17

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV CYPRESS_VERSION=13.15.1
ENV NODE_JS_VERSION=20.x
ENV CYPRESS_BASE_URL=https://dev.rapid-cc-sandbox-cgmalone.rapid.intellibridgelabs.io

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget curl gnupg xvfb libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xz-utils openssl unzip \
    libgbm-dev libgtk2.0-0 libgdk-pixbuf2.0-0 libatk1.0-0 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libglib2.0-0 \
    libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
    libxfixes3 libxi6 libxrandr2 libxrender1 ca-certificates fonts-liberation libappindicator1 lsb-release xdg-utils jq software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*
    
# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_JS_VERSION} | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
# Set up Cypress cache directory
RUN mkdir -p /home/jenkins/.cache/Cypress 

WORKDIR /home/jenkins/workspace

# Copy package.json and package-lock.json if available
COPY --chown=jenkins:jenkins package*.json tsconfig.json ./
RUN npm install cypress@${CYPRESS_VERSION}
RUN npx cypress verify
RUN npm install typescript --save-dev
