#!/bin/bash
# background.sh - Pre-carga de dependencias mientras el asistente lee la intro.
# Todo es "best effort": si algo falla, los pasos del escenario siguen
# funcionando igual (solo serán más lentos). Log en /var/log/scenario-setup.log

export DEBIAN_FRONTEND=noninteractive
LOG=/var/log/scenario-setup.log
exec >>"$LOG" 2>&1
echo "=== setup start: $(date -u +%T) ==="

NE_VERSION="1.12.1"
NE_TARBALL="node_exporter-${NE_VERSION}.linux-amd64.tar.gz"
NE_URL="https://github.com/prometheus/node_exporter/releases/download/v${NE_VERSION}/${NE_TARBALL}"

# retry <intentos> <comando...>  (backoff lineal: 3s, 6s, 9s...)
retry() {
  local n=$1 i; shift
  for ((i = 1; i <= n; i++)); do
    "$@" && return 0
    echo "[retry] intento $i/$n falló: $*"
    sleep $((i * 3))
  done
  return 1
}

wait_for_docker() {
  for _ in $(seq 1 60); do
    docker info >/dev/null 2>&1 && return 0
    sleep 2
  done
  return 1
}

# pull_image <imagen-final> [fuente-alternativa ...]
# Intenta Docker Hub y, si falla (p. ej. rate limit por IP compartida),
# prueba mirrors y re-etiqueta la imagen con el nombre que usa docker-compose.yml
pull_image() {
  local target=$1; shift
  docker image inspect "$target" >/dev/null 2>&1 && return 0
  retry 3 docker pull "$target" && return 0
  local src
  for src in "$@"; do
    if retry 2 docker pull "$src"; then
      docker tag "$src" "$target" && return 0
    fi
  done
  echo "[warn] no se pudo precargar $target"
  return 1
}

download_node_exporter() {
  [ -s "/root/$NE_TARBALL" ] && return 0
  retry 4 wget -q -O "/root/$NE_TARBALL.part" "$NE_URL" \
    && mv "/root/$NE_TARBALL.part" "/root/$NE_TARBALL"
}

install_tree() {
  retry 3 apt-get update -qq && retry 3 apt-get install -y -qq tree
}

# Compatibilidad: los pasos usan `docker-compose`; si la imagen solo trae
# el plugin `docker compose`, crea un shim para que no falle.
ensure_compose_shim() {
  if ! command -v docker-compose >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    printf '#!/bin/sh\nexec docker compose "$@"\n' > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  fi
}

# --- Todo en paralelo para minimizar el tiempo total ---
install_tree &
download_node_exporter &
(
  wait_for_docker || { echo "[warn] docker no está listo"; exit 0; }
  ensure_compose_shim
  pull_image "prom/prometheus:v3" \
    "quay.io/prometheus/prometheus:v3" \
    "mirror.gcr.io/prom/prometheus:v3" &
  pull_image "grafana/grafana:11.6" \
    "mirror.gcr.io/grafana/grafana:11.6" &
  wait
) &
wait

echo "=== setup end: $(date -u +%T) ==="
docker images --format '{{.Repository}}:{{.Tag}}' | grep -E 'prometheus|grafana'
ls -lh "/root/$NE_TARBALL" 2>/dev/null
touch /tmp/.setup-done
