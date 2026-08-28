#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
# Windows-like notifications and clipboard history for the Xfce desktop.
apt-get update
apt-get install -y python3-tk xfce4-goodies xfce4-appfinder xfce4-session xfce4-workspaces xfce4-power-manager xfce4-pulseaudio-plugin xfce4-notifyd xfce4-clipman xfce4-clipman-plugin xfce4-screenshooter xfce4-taskmanager zenity
install -Dm755 "$ROOT/usr/local/bin/np300e5x-updater" /usr/local/bin/np300e5x-updater
install -Dm644 "$ROOT/usr/share/applications/np300e5x-updater.desktop" /usr/share/applications/np300e5x-updater.desktop
install -Dm755 "$ROOT/usr/local/bin/zenith-menu" /usr/local/bin/zenith-menu
install -Dm755 "$ROOT/usr/local/bin/zenith-welcome" /usr/local/bin/zenith-welcome
install -Dm755 "$ROOT/usr/local/bin/zenith-mintinstall" /usr/local/bin/zenith-mintinstall
install -Dm755 "$ROOT/usr/local/bin/zenith-app-center" /usr/local/bin/zenith-app-center
install -Dm755 "$ROOT/usr/local/bin/zenith-account" /usr/local/bin/zenith-account
install -Dm755 "$ROOT/usr/local/bin/zenith-nvidia-check" /usr/local/bin/zenith-nvidia-check
install -Dm755 "$ROOT/usr/local/sbin/install-mintinstall-8.4.0" /usr/local/sbin/install-mintinstall-8.4.0
install -Dm644 "$ROOT/usr/share/applications/zenith-menu.desktop" /usr/share/applications/zenith-menu.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-mintinstall.desktop" /usr/share/applications/zenith-mintinstall.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-app-center.desktop" /usr/share/applications/zenith-app-center.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-account.desktop" /usr/share/applications/zenith-account.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-nvidia-check.desktop" /usr/share/applications/zenith-nvidia-check.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-welcome.desktop" /etc/xdg/autostart/zenith-welcome.desktop
install -Dm644 "$ROOT/usr/share/applications/zenith-update-startup.desktop" /etc/xdg/autostart/zenith-update-startup.desktop
install -Dm644 "$ROOT/etc/np300e5x/version" /etc/np300e5x/version
install -Dm644 "$ROOT/etc/profile.d/zenith-dark-theme.sh" /etc/profile.d/zenith-dark-theme.sh
install -d -m755 /var/cache/np300e5x-updater /var/backups/np300e5x
install -Dm644 "$ROOT/etc/np300e5x/version" /etc/np300e5x/version
install -Dm644 "$ROOT/etc/profile.d/zenith-dark-theme.sh" /etc/profile.d/zenith-dark-theme.sh
printf '%s\n' 'Обновлятор NP300E5X установлен.'
