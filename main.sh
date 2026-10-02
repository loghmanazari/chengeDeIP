#!/bin/bash

while true; do
    read -rp "Mode (iran/kharej): " MODE
    case "$MODE" in
        iran|kharej) break ;;
        *) echo "Please enter 'iran' or 'kharej'." ;;
    esac
done

while true; do
    read -rp "Enter new IP: " NEW_IP
    [[ -n "$NEW_IP" ]] && break
    echo "IP cannot be empty!"
done

KEY="listen_ip"
[[ "$MODE" == "iran" ]] && KEY="dst_ip"

PROFILE=""

systemctl daemon-reload

for file in /root/backhaul-core/*.toml; do
    [[ -f "$file" ]] || continue

    name=$(basename "$file" .toml)

    echo "Updating $file..."

    sed -i -E "s|^([[:space:]]*${KEY}[[:space:]]*=[[:space:]]*\").*(\")|\1${NEW_IP}\2|" "$file"

    # فقط از اولین فایل مقدار profile را می‌خوانیم
    if [[ -z "$PROFILE" ]]; then
        PROFILE=$(grep -m1 '^profile[[:space:]]*=' "$file" | cut -d'"' -f2)
    fi

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
echo "Profile : ${PROFILE:-Unknown}"
echo "New IP  : $NEW_IP"
echo "Mode    : $MODE"
echo "Done."
