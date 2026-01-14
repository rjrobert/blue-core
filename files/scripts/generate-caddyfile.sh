#!/bin/bash
# Generate Caddyfile from container labels
# Scans /etc/containers/*.container for caddy.port labels and uses ContainerName as subdomain

set -oue pipefail

CADDYFILE="/etc/caddy/Caddyfile"
CONTAINER_DIR="/etc/containers"

# Ensure caddy config directory exists
mkdir -p "$(dirname "$CADDYFILE")"

# Write header and global settings
cat >"$CADDYFILE" <<'EOF'
{
	auto_https prefer_wildcard
}

*.{$CADDY_DOMAIN} {
	tls {
		dns cloudflare {$CLOUDFLARE_API_TOKEN}
	}
}
EOF

# Scan container files for caddy labels
container_count=$(find "$CONTAINER_DIR" -maxdepth 1 -name "*.container" 2>/dev/null | wc -l)
if [[ "$container_count" -eq 0 ]]; then
  echo "Warning: No .container files found in $CONTAINER_DIR"
fi

for container_file in "$CONTAINER_DIR"/*.container; do
  [ -f "$container_file" ] || continue

  container_name=$(grep -E "^ContainerName=" "$container_file" | cut -d= -f2)
  port=$(grep -E "^Label=caddy\.port=" "$container_file" | cut -d= -f3)

  if [[ -n "$container_name" && -n "$port" ]]; then
    cat >>"$CADDYFILE" <<EOF

${container_name}.{\$CADDY_DOMAIN} {
	reverse_proxy ${container_name}:${port}
}
EOF
  fi
done

echo "Generated $CADDYFILE with $(grep -c 'reverse_proxy' "$CADDYFILE" || echo 0) service entries"
