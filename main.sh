#!/bin/bash

while true; do
    echo "Select mode:"
    echo "1) Iran (change dst_ip)"
    echo "2) Kharej (change listen_ip)"
    read -rp "Choice [1-2]: " CHOICE

    case "$CHOICE" in
        1)
            MODE="iran"
            KEY="dst_ip"
            break
            ;;
        2)
            MODE="kharej"
            KEY="listen_ip"
            break
            ;;
        *)
            echo "Please enter 1 or 2."
            ;;
    esac
done

while true; do
    read -rp "Enter new IP: " NEW_IP
    [[ -n "$NEW_IP" ]] && break
    echo "IP cannot be empty!"
done

PROFILE=""

systemctl daemon-reload

for file in /root/backhaul-core/*.toml; do
    [[ -f "$file" ]] || continue

    name=$(basename "$file" .toml)

    echo "Updating $file..."

    sed -i -E "s|^([[:space:]]*${KEY}[[:space:]]*=[[:space:]]*\").*(\")|\1${NEW_IP}\2|" "$file"

    [[ -z "$PROFILE" ]] && PROFILE=$(grep -m1 '^profile[[:space:]]*=' "$file" | cut -d'"' -f2)

    service="backhaul-${name}"

    echo "Restarting $service..."
    systemctl restart "$service"

    if systemctl is-active --quiet "$service"; then
        echo "✓ $service restarted successfully"
    else
        echo "✗ $service failed to restart"
    fi

    echo
done

echo "================================"
echo "Mode    : $MODE"
echo "Profile : ${PROFILE:-Unknown}"
echo "New IP  : $NEW_IP"
echo "Done."
