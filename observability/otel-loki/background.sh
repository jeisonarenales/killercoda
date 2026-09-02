#!/bin/env bash
set -euxo pipefail

OTELCOL_CONTRIB_VERSION="0.159.0"
ARCH="$(dpkg --print-architecture)"
DEB_FILE="otelcol-contrib_${OTELCOL_CONTRIB_VERSION}_linux_${ARCH}.deb"
DOWNLOAD_URL="https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTELCOL_CONTRIB_VERSION}/${DEB_FILE}"
WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

# Skip if already installed at this version
if command -v otelcol-contrib >/dev/null 2>&1; then
  INSTALLED_VERSION="$(otelcol-contrib --version | awk '{print $NF}')"
  if [ "${INSTALLED_VERSION}" = "${OTELCOL_CONTRIB_VERSION}" ]; then
    echo "otelcol-contrib ${OTELCOL_CONTRIB_VERSION} ya está instalado. Nada que hacer."
    exit 0
  fi
fi

apt-get update
apt-get -y install wget

cd "${WORK_DIR}"

wget -O "${DEB_FILE}" "${DOWNLOAD_URL}"
wget -O checksums.txt "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTELCOL_CONTRIB_VERSION}/opentelemetry-collector-releases_otelcol-contrib_checksums.txt"

# Verify checksum before installing anything downloaded from the internet
if ! grep "${DEB_FILE}$" checksums.txt | sha256sum -c -; then
  echo "ERROR: checksum verification failed for ${DEB_FILE}" >&2
  exit 1
fi

dpkg -i "${DEB_FILE}"

systemctl enable otelcol-contrib
systemctl restart otelcol-contrib

# Fail loudly if the service did not come up
systemctl is-active --quiet otelcol-contrib || {
  echo "ERROR: otelcol-contrib service is not active" >&2
  journalctl -u otelcol-contrib --no-pager -n 50
  exit 1
}

echo "otelcol-contrib ${OTELCOL_CONTRIB_VERSION} instalado y corriendo."