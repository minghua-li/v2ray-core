#!/usr/bin/env bash
#
# macos-release.sh — build, sign, package, and publish a v2ray-mli macOS release.
#
# Builds native darwin/arm64 and darwin/amd64 binaries, code-signs them with a
# Developer ID, bundles them with the geo data and a sample config, generates
# SHA256SUMS, creates the mli-v<version> git tag, and publishes a GitHub release.
#
# Usage:
#   SIGN_IDENTITY="Developer ID Application: Name (TEAMID)" release/macos-release.sh <version>
#
# Example:
#   SIGN_IDENTITY="Developer ID Application: Minghua Li (BP2377Z56T)" \
#     release/macos-release.sh 4.31.1
#
# Environment:
#   SIGN_IDENTITY  (required)  codesign identity. If unset/empty, binaries are
#                              left ad-hoc signed (arm64) and the release is
#                              marked unsigned.
#   SKIP_PUBLISH   (optional)  if set, build/sign/package only — no tag/release.
#   OUT_DIR        (optional)  output directory (default: ./dist).

set -euo pipefail

VERSION="${1:?usage: macos-release.sh <version>  (e.g. 4.31.1)}"
TAG="mli-v${VERSION}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-${REPO_ROOT}/dist}"
CONFIG_DIR="${REPO_ROOT}/release/config"

cd "${REPO_ROOT}"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

build_arch() {
  local arch="$1"
  local stage="${OUT_DIR}/v2ray-mli-macos-${arch}"
  echo ">> building darwin/${arch}"
  mkdir -p "${stage}"

  GOOS=darwin GOARCH="${arch}" go build \
    -ldflags "-s -w -X v2ray.com/core.build=mli-${arch}" \
    -o "${stage}/v2ray" ./main/
  GOOS=darwin GOARCH="${arch}" go build \
    -ldflags "-s -w -X v2ray.com/core.build=mli-${arch}" \
    -o "${stage}/v2ctl" ./infra/control/main/

  cp "${CONFIG_DIR}/geoip.dat"   "${stage}/geoip.dat"
  cp "${CONFIG_DIR}/geosite.dat" "${stage}/geosite.dat"
  cp "${CONFIG_DIR}/config.json" "${stage}/config.json"

  if [ -n "${SIGN_IDENTITY:-}" ]; then
    echo ">> signing darwin/${arch} with: ${SIGN_IDENTITY}"
    codesign --force --timestamp --options runtime \
      --sign "${SIGN_IDENTITY}" "${stage}/v2ray" "${stage}/v2ctl"
    codesign --verify --strict "${stage}/v2ray"
    codesign --verify --strict "${stage}/v2ctl"
  else
    echo ">> SIGN_IDENTITY not set — leaving binaries ad-hoc signed"
  fi

  ( cd "${OUT_DIR}" && zip -qr -X "v2ray-mli-macos-${arch}.zip" "v2ray-mli-macos-${arch}" )
  rm -rf "${stage}"
  echo ">> packaged ${OUT_DIR}/v2ray-mli-macos-${arch}.zip"
}

build_arch arm64
build_arch amd64

echo ">> generating SHA256SUMS"
( cd "${OUT_DIR}" && shasum -a 256 ./*.zip > SHA256SUMS && cat SHA256SUMS )

if [ -n "${SKIP_PUBLISH:-}" ]; then
  echo ">> SKIP_PUBLISH set — done (no tag/release)."
  exit 0
fi

echo ">> tagging ${TAG}"
git tag -a "${TAG}" -m "v2ray-mli ${VERSION}"
git push origin "${TAG}"

echo ">> creating GitHub release ${TAG}"
gh release create "${TAG}" \
  --title "v2ray-mli ${VERSION}" \
  --notes-file <(awk "/^## \[${VERSION}-mli\]/{f=1;next} /^## \[/{f=0} f" "${REPO_ROOT}/CHANGELOG.md") \
  "${OUT_DIR}/v2ray-mli-macos-arm64.zip" \
  "${OUT_DIR}/v2ray-mli-macos-amd64.zip" \
  "${OUT_DIR}/SHA256SUMS"

echo ">> done: https://github.com/minghua-li/v2ray-core/releases/tag/${TAG}"
