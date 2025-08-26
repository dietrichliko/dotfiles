#!/bin/bash
# Maintain Bitwarden CLI
# Dietrich Liko (and ChatGPT)

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
BW_BIN="$INSTALL_DIR/bw"
API_URL="https://api.github.com/repos/bitwarden/clients/releases"

mkdir -p "$INSTALL_DIR"

# Determine platform
case "$(uname -s)" in
  Linux*)   PLATFORM="linux" ;;
  Darwin*)  PLATFORM="macos" ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

echo "Fetching Bitwarden CLI releases..."
RELEASES_JSON=$(curl -s "$API_URL")

# Get latest tag starting with cli-
LATEST_TAG=$(echo "$RELEASES_JSON" | jq -r '.[].tag_name | select(startswith("cli-"))' \
  | sed 's/^cli-v//' \
  | sort -V \
  | tail -n1)

if [[ -z "$LATEST_TAG" ]]; then
  echo "No CLI release tags found."
  exit 1
fi

LATEST_TAG_FULL="cli-v$LATEST_TAG"
ASSET_NAME="bw-${PLATFORM}-${LATEST_TAG}.zip"

echo "Latest CLI release: $LATEST_TAG_FULL"
echo "Looking for asset: $ASSET_NAME"

# Find asset download URL
DOWNLOAD_URL=$(echo "$RELEASES_JSON" \
  | jq -r --arg TAG "$LATEST_TAG_FULL" --arg ASSET "$ASSET_NAME" '
    .[] | select(.tag_name == $TAG) |
    .assets[] | select(.name == $ASSET) |
    .browser_download_url
')

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "Could not find asset $ASSET_NAME in release $LATEST_TAG_FULL"
  exit 1
fi

# Check installed version
if [[ -x "$BW_BIN" ]]; then
  INSTALLED_VERSION=$("$BW_BIN" --version 2>/dev/null || echo "none")
  echo "$INSTALLED_VERSION - $LATEST_TAG"
  if [[ "$INSTALLED_VERSION" == "$LATEST_TAG" ]]; then
    echo "Bitwarden CLI is already up-to-date ($INSTALLED_VERSION)."
    exit 0
  else
    echo "Updating Bitwarden CLI ($INSTALLED_VERSION → $LATEST_TAG)"
  fi
else
  echo "Installing Bitwarden CLI $LATEST_TAG"
fi

# Download and install
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
curl -s -L -o bw.zip "$DOWNLOAD_URL"
unzip -o bw.zip
mv bw "$INSTALL_DIR/"
chmod +x "$BW_BIN"
cd -
rm -rf "$TMPDIR"

echo "Bitwarden CLI $LATEST_TAG_FULL installed at $BW_BIN"

