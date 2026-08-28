#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
install -Dm755 "$ROOT/usr/local/bin/np300e5x-updater" /usr/local/bin/np300e5x-updater
install -Dm644 "$ROOT/usr/share/applications/np300e5x-updater.desktop" /usr/share/applications/np300e5x-updater.desktop
install -Dm644 "$ROOT/etc/np300e5x/version" /etc/np300e5x/version
install -d -m755 /var/cache/np300e5x-updater /var/backups/np300e5x
printf '%s\n' 'Обновлятор NP300E5X установлен.'
