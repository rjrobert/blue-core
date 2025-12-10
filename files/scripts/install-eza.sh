#!/usr/bin/env bash

set -oue pipefail

curl --fail --retry 15 --retry-all-errors -sSL -o /tmp/eza.tar.gz https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O -
tar zx /tmp/eza.tar.gz -C /tmp
sudo chmod +x /tmp/eza
sudo chown root:root /tmp/eza
sudo mv /tmp/eza /usr/local/bin/eza
