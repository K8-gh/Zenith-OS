#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
# Windows-like notifications and clipboard history for the Xfce desktop.
apt-get update
apt-get install -y xfce4-goodies xfce4-appfinder xfce4-session xfce4-workspaces xfce4-power-manager xfce4-pulseaudio-plugin xfce4-notifyd xfce4-clipman xfce4-clipman-plugin xfce4-screenshooter xfce4-taskmanager
install -Dm755 "$ROOT/usr/local/bin/np300e5x-updater" /usr/local/bin/np300e5x-updater
install -Dm644 "$ROOT/usr/share/applications/np300e5x-updater.desktop" /usr/share/applications/np300e5x-updater.desktop
install -Dm755 "$ROOT/usr/local/bin/zenith-menu" /usr/local/bin/zenith-menu
install -Dm755 "$ROOT/usr/local/bin/zenith-welcome" /usr/local/bin/zenith-welcome
install -Dm644 "$ROOT/usr/share/applications/zenith-menu.desktop" /usr/share/applications/zenith-menu.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-welcome.desktop" /etc/xdg/autostart/zenith-welcome.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-update-startup.desktop" /etc/xdg/autostart/zenith-update-startup.desktop
install -Dm644 "$ROOT/etc/np300e5x/version" /etc/np300e5x/version
install -d -m755 /var/cache/np300e5x-updater /var/backups/np300e5x
install -Dm644 "$ROOT/etc/np300e5x/version" /etc/np300e5x/version
printf '%s\n' 'Обновлятор NP300E5X установлен.'
