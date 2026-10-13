#!/usr/bin/env bash

set -oue pipefail

# Release assets include the version, so resolve the latest tag first.
latest_url=$(curl --fail --retry 15 --retry-all-errors -sSLI -o /dev/null \
  -w '%{url_effective}' https://github.com/nushell/nushell/releases/latest)
version=${latest_url##*/}
name="nu-${version}-x86_64-unknown-linux-gnu"

curl --fail --retry 15 --retry-all-errors -sSL -o /tmp/nu.tar.gz \
  "https://github.com/nushell/nushell/releases/download/${version}/${name}.tar.gz"
tar zxf /tmp/nu.tar.gz -C /tmp
for bin in nu nu_plugin_query nu_plugin_formats nu_plugin_inc; do
  install -o root -g root -m 0755 "/tmp/${name}/${bin}" "/usr/bin/${bin}"
done
rm -rf /tmp/nu.tar.gz "/tmp/${name}"
