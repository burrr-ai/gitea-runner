# Ubuntu 기반으로 시작
FROM --platform=linux/amd64 ubuntu:22.04

# 기본 패키지 설치 (tini 포함)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils \
    build-essential python3 wget tini \
    && rm -rf /var/lib/apt/lists/*

# act_runner 설치
ENV ACT_RUNNER_VERSION=0.2.13
RUN curl -fsSL https://dl.gitea.com/act_runner/${ACT_RUNNER_VERSION}/act_runner-${ACT_RUNNER_VERSION}-linux-amd64 -o /usr/local/bin/act_runner && \
    chmod +x /usr/local/bin/act_runner

# Node 20 LTS + corepack (pnpm 포함)
ENV NODE_VERSION=20.18.1
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz | \
    tar -xJ -C /usr/local --strip-components=1 && \
    node --version && \
    npm --version && \
    npm install -g corepack && \
    corepack enable

# 러너 작업 디렉토리/캐시
ENV RUNNER_HOME=/data
ENV HOME=/data/home
ENV PNPM_HOME=/data/.pnpm
ENV npm_config_cache=/data/.npm
RUN mkdir -p $RUNNER_HOME $HOME $PNPM_HOME /data/.npm

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]