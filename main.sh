#!/bin/bash

while true; do
    read -rp "Enter new listen_ip: " NEW_IP
    [[ -n "$NEW_IP" ]] && break
    echo "listen_ip cannot be empty!"
done

for file in /root/backhaul-core/*.toml; do
    [[ -f "$file" ]] || continue

    name=$(basename "$file" .toml)

    echo "Updating $file..."

    sed -i -E "s|^([[:space:]]*listen_ip[[:space:]]*=[[:space:]]*\").*(\")|\1${NEW_IP}\2|" "$file"

    service="backhaul-${name}"

    echo "Restarting $service..."
    systemctl daemon-reload
    systemctl restart "$service"

    if systemctl is-active --quiet "$service"; then
        echo "✓ $service restarted successfully"
    else
        echo "✗ $service failed to restart"
    fi

    echo
done

echo "Done."
