#!/usr/bin/env nu
# Generate Caddyfile from container labels
# Scans /etc/containers/*.container for caddy.port labels and uses ContainerName as subdomain

let caddyfile = "./Caddyfile"
let container_dir = "files/docker-vm/etc/containers"
# let caddyfile = "/etc/caddy/Caddyfile"
# let container_dir = "/etc/containers"

# Ensure caddy config directory exists
mkdir ($caddyfile | path dirname)

# Write header and global settings
"{
	auto_https prefer_wildcard
}

*.{$CADDY_DOMAIN} {
	tls {
		dns cloudflare {$CLOUDFLARE_API_TOKEN}
	}
}
" | save -f $caddyfile

# Find container files
let container_files = (glob $"($container_dir)/*.container")

if ($container_files | is-empty) {
    print $"Warning: No .container files found in ($container_dir)"
}

# Process each container file
let entries = ($container_files | each { |file|
    let content = (open $file --raw)

    let container_name = ($content | rg '^ContainerName=(.+)' -r '$1' | str trim)
    let port = ($content | rg '^Label=caddy\.port=(.+)' -r '$1' | str trim)

    if ($container_name | is-not-empty) and ($port | is-not-empty) {
        $"
($container_name).{$CADDY_DOMAIN} {
	reverse_proxy ($container_name):($port)
}
"
    } else {
        ""
    }
} | where { |entry| $entry | is-not-empty })

# Append entries to Caddyfile
$entries | str join "" | save -a $caddyfile

print $"Generated ($caddyfile) with ($entries | length) service entries"
