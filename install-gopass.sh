#!/usr/bin/env bash
set -euo pipefail

url=$(curl -s https://api.github.com/repos/gopasspw/gopass/releases/latest \
  | jq -r '.assets[] | select(.name | test("linux-amd64\\.tar\\.gz$")) | .browser_download_url')

curl -L "$url" \
  | sudo tar -xz -C /usr/local/bin  gopass
