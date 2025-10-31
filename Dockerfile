# gitea act-runner 베이스
FROM --platform=linux/amd64 gitea/act_runner:latest

# 기본 유틸 + 빌드 도구 (Alpine)
RUN apk add --no-cache \
    ca-certificates curl git unzip xz bash \
    build-base python3 linux-headers \
    gcompat libc6-compat

# Node 20 LTS + corepack (pnpm 포함)
RUN apk add --no-cache nodejs npm
RUN npm install -g corepack && corepack enable

# 러너 작업 디렉토리/캐시
ENV RUNNER_HOME=/data
ENV HOME=/data/home
ENV PNPM_HOME=/data/.pnpm
ENV npm_config_cache=/data/.npm
RUN mkdir -p $RUNNER_HOME $HOME $PNPM_HOME /data/.npm

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]