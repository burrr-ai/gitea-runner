#!/usr/bin/env bash
set -euo pipefail

: "${GITEA_INSTANCE_URL:?Set GITEA_INSTANCE_URL}"
: "${GITEA_RUNNER_REGISTRATION_TOKEN:?Set GITEA_RUNNER_REGISTRATION_TOKEN}"

GITEA_RUNNER_NAME="${GITEA_RUNNER_NAME:-railway-runner}"
GITEA_RUNNER_LABELS="${GITEA_RUNNER_LABELS:-self-hosted,ubuntu-latest}"
GITEA_RUNNER_CAPACITY="${GITEA_RUNNER_CAPACITY:-1}"
GITEA_RUNNER_EPHEMERAL="${GITEA_RUNNER_EPHEMERAL:-false}"

# PATH 설정 (pnpm, node 등)
export PATH="/usr/local/bin:/usr/bin:/bin:$PNPM_HOME:$PATH"

mkdir -p /data /data/home /data/.pnpm /data/.npm
chown -R root:root /data

CFG="/data/config.yaml"
if [ ! -f "$CFG" ]; then
  cat > "$CFG" <<'YAML'
log:
  level: info

runner:
  capacity: __CAPACITY__
  labels:
    - "self-hosted"
    - "ubuntu-latest:host"

executor:
  type: host
YAML
  sed -i "s/__CAPACITY__/${GITEA_RUNNER_CAPACITY}/" "$CFG"
fi

if [ ! -f /data/.runner ]; then
  echo "[register] first-time registration..."
  REGISTER_CMD="act_runner register --no-interactive --instance ${GITEA_INSTANCE_URL} --token ${GITEA_RUNNER_REGISTRATION_TOKEN} --name ${GITEA_RUNNER_NAME} --labels ${GITEA_RUNNER_LABELS} --config $CFG"

  if [ "${GITEA_RUNNER_EPHEMERAL}" = "true" ]; then
    REGISTER_CMD="${REGISTER_CMD} --ephemeral"
  fi

  eval $REGISTER_CMD
else
  echo "[register] .runner exists; skip"
fi

echo "[daemon] starting..."
exec act_runner daemon --config "$CFG"