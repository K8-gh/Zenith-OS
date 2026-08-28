#!/usr/bin/env bash
set -Eeuo pipefail

# Build a custom Debian live ISO. Run on Debian 13 amd64 or a compatible Debian host.
# The resulting image is a live installer base; test it before installing to disk.

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Запускайте сборку обычным пользователем с sudo-доступом."
  exit 1
fi

sudo apt-get update
sudo apt-get install -y live-build debootstrap xorriso squashfs-tools git ca-certificates
rm -rf live-build-np300e5x
mkdir -p live-build-np300e5x
cd live-build-np300e5x

lb config \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free non-free-firmware" \
  --debian-installer live \
  --debian-installer-gui true \
  --bootappend-live "boot=live components locales=ru_RU.UTF-8 keyboard-layouts=ru keyboard-model=pc105" \
  --iso-application "Zenith OS" \
  --iso-publisher "Community build" \
  --iso-volume "ZENITH-OS" \
  --memtest none \
  --apt-recommends true

mkdir -p config/package-lists config/includes.chroot/usr/local/sbin config/hooks/live config/includes.binary/boot/grub
cp ../scripts/grub/custom.cfg config/includes.binary/boot/grub/custom.cfg
# Include the updater files in the live filesystem; install.sh runs in the chroot hook.
mkdir -p config/includes.chroot/usr/local/lib/np300e5x-updater config/includes.chroot/usr/local/bin config/includes.chroot/usr/share/applications config/includes.chroot/etc/np300e5x config/includes.chroot/etc/xdg/autostart
cp ../updater/package/usr/local/bin/np300e5x-updater config/includes.chroot/usr/local/bin/
cp ../updater/package/usr/local/bin/zenith-menu config/includes.chroot/usr/local/bin/
cp ../updater/package/usr/local/bin/zenith-welcome config/includes.chroot/usr/local/bin/
cp ../updater/package/usr/local/bin/zenith-installer config/includes.chroot/usr/local/bin/
cp ../updater/package/usr/local/bin/zenith-mintinstall config/includes.chroot/usr/local/bin/
cp ../updater/package/usr/local/bin/zenith-app-center config/includes.chroot/usr/local/bin/
cp ../updater/package/usr/local/bin/zenith-account config/includes.chroot/usr/local/bin/
cp ../updater/package/usr/local/sbin/install-mintinstall-8.4.0 config/includes.chroot/usr/local/sbin/
mkdir -p config/includes.chroot/etc/profile.d
cp ../updater/package/etc/profile.d/zenith-dark-theme.sh config/includes.chroot/etc/profile.d/
cp ../updater/package/usr/share/applications/zenith-welcome.desktop config/includes.chroot/etc/xdg/autostart/
cp ../updater/package/usr/share/applications/zenith-update-startup.desktop config/includes.chroot/etc/xdg/autostart/
cp ../updater/package/usr/share/applications/zenith-menu.desktop config/includes.chroot/usr/share/applications/
cp ../updater/package/usr/share/applications/zenith-installer.desktop config/includes.chroot/usr/share/applications/
cp ../updater/package/usr/share/applications/zenith-mintinstall.desktop config/includes.chroot/usr/share/applications/
cp ../updater/package/usr/share/applications/zenith-app-center.desktop config/includes.chroot/usr/share/applications/
cp ../updater/package/usr/share/applications/zenith-account.desktop config/includes.chroot/usr/share/applications/
cp ../updater/package/usr/share/applications/np300e5x-updater.desktop config/includes.chroot/usr/share/applications/
cp ../updater/package/etc/np300e5x/version config/includes.chroot/etc/np300e5x/
cp ../updater/package/install.sh config/includes.chroot/usr/local/lib/np300e5x-updater/
cp -a ../updater/package/usr/local/bin/np300e5x-updater config/includes.chroot/usr/local/lib/np300e5x-updater/
cat > config/hooks/live/0999-install-zenith-updater.hook.chroot <<'HOOK'
#!/bin/sh
set -e
chmod 0755 /usr/local/bin/np300e5x-updater
mkdir -p /var/cache/np300e5x-updater /var/backups/np300e5x
chmod 0700 /var/backups/np300e5x
HOOK
chmod +x config/hooks/live/0999-install-zenith-updater.hook.chroot
cat > config/package-lists/np300e5x.list.chroot <<'EOF'
task-xfce-desktop
lightdm
lightdm-gtk-greeter
calamares
os-prober
debian-installer-launcher
xfce4-settings
xfce4-terminal
xfce4-panel
thunar
xfce4-whiskermenu-plugin
menulibre
xfce4-goodies
xfce4-appfinder
xfce4-session
xfce4-workspaces
xfce4-power-manager
xfce4-pulseaudio-plugin
xfce4-notifyd
xfce4-clipman
xfce4-clipman-plugin
firefox-esr
firefox-esr-l10n-ru
network-manager
network-manager-gnome
bluez
blueman
rfkill
firmware-linux
firmware-linux-nonfree
firmware-atheros
firmware-iwlwifi
firmware-realtek
firmware-brcm80211
wireguard-tools
python3
python3-tk
mesa-utils
mesa-vulkan-drivers
xserver-xorg-video-intel
pavucontrol
pipewire
pipewire-pulse
wireplumber
cups
system-config-printer
simple-scan
gufw
synaptic
gnome-software
gnome-software-plugin-flatpak
flatpak
xdg-desktop-portal-gtk
default-jre
libreoffice
libreoffice-l10n-ru
gimp
mousepad
ristretto
galculator
xfce4-screenshooter
xfce4-taskmanager
zenity
arc-theme
papirus-icon-theme
gtk2-engines-murrine
adwaita-icon-theme
catfish
network-manager-openvpn
network-manager-openconnect
inkscape
audacity
file-roller
gparted
baobab
exfatprogs
ntfs-3g
hplip
remmina
transmission-gtk
thunderbird
thunderbird-l10n-ru
aisleriot
gnome-mines
gnome-sudoku
neverball
supertux
frozen-bubble
gdebi
timeshift
vlc
ffmpeg
tlp
thermald
powertop
inxi
lm-sensors
locales
fonts-noto-core
fonts-liberation
appstream
EOF

cat > config/hooks/live/0500-zenith.hook.chroot <<'EOF'
#!/bin/sh
set -e
sed -i -E 's/^# *ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen || true
locale-gen || true
update-locale LANG=ru_RU.UTF-8 LANGUAGE=ru_RU:ru LC_ALL=ru_RU.UTF-8 || true
systemctl enable NetworkManager || true
systemctl enable bluetooth || true
systemctl enable lightdm || true
systemctl enable cups || true
systemctl enable tlp || true
systemctl disable NetworkManager-wait-online.service 2>/dev/null || true
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
flatpak install -y flathub org.prismlauncher.PrismLauncher || true
curl -fsSL https://elyprismlauncher.github.io/flatpak/elyprismlauncher.flatpakref -o /tmp/elyprismlauncher.flatpakref || true
flatpak install -y /tmp/elyprismlauncher.flatpakref 2>/dev/null || true
rm -f /tmp/elyprismlauncher.flatpakref

# Bundle the current official amd64 hide.me CLI release into the image.
python3 - <<'PY'
import json, pathlib, urllib.request, tarfile, tempfile
api = urllib.request.Request('https://api.github.com/repos/eventure/hide.client.linux/releases/latest', headers={'Accept':'application/vnd.github+json','User-Agent':'np300e5x-live-build'})
with urllib.request.urlopen(api, timeout=30) as r:
    rel = json.load(r)
assets = [a for a in rel.get('assets', []) if 'linux-amd64' in a.get('name', '')]
if not assets:
    raise SystemExit('hide.me amd64 release asset not found')
with tempfile.TemporaryDirectory() as d:
    archive = pathlib.Path(d) / 'hide.tar.gz'
    urllib.request.urlretrieve(assets[0]['browser_download_url'], archive)
    with tarfile.open(archive) as t:
        t.extractall('/opt/hide.me')
PY
mkdir -p /usr/local/share/applications
cat > /usr/local/share/applications/np300e5x-app-center.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Центр приложений
Comment=Установка и обновление программ из Debian и Flatpak
Exec=gnome-software
Icon=gnome-software
Terminal=false
Categories=System;PackageManager;
DESKTOP
cat > /usr/local/share/applications/np300e5x-prism.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Prism Launcher
Comment=Менеджер сборок Minecraft
Exec=flatpak run org.prismlauncher.PrismLauncher
Icon=org.prismlauncher.PrismLauncher
Terminal=false
Categories=Game;
DESKTOP
cat > /usr/local/share/applications/np300e5x-elyprism.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=PineconeMC / ElyPrism
Comment=Лаунчер Minecraft с поддержкой Ely.by
Exec=flatpak run org.elyprismlauncher.Launcher
Icon=org.elyprismlauncher.Launcher
Terminal=false
Categories=Game;
DESKTOP
cat > /usr/local/share/applications/np300e5x-desktop-settings.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Настройки рабочего стола
Comment=Панель, темы, обои, значки и окна Xfce
Exec=xfce4-settings-manager
Icon=preferences-desktop
Terminal=false
Categories=Settings;DesktopSettings;
DESKTOP
cat > /usr/local/share/applications/np300e5x-os-settings.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Настройки ОС
Comment=Сеть, Bluetooth, звук, экран, питание и безопасность
Exec=xfce4-settings-manager
Icon=preferences-system
Terminal=false
Categories=Settings;System;
DESKTOP
cat > /usr/local/share/applications/hide-me-vpn.desktop <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=hide.me VPN
Name[ru]=hide.me VPN
Comment=Официальный WireGuard-клиент hide.me
Exec=xfce4-terminal --title="hide.me VPN" -e /opt/hide.me/hide.me
Icon=network-vpn
Terminal=false
Categories=Network;Security;
DESKTOP
chmod +x /opt/hide.me/hide.me 2>/dev/null || true
# Put a visible installer shortcut in the live user's desktop.
install -d -m755 /etc/skel/Desktop
cp /usr/share/applications/zenith-installer.desktop /etc/skel/Desktop/Установить\ Zenith\ OS.desktop
chmod 0755 /etc/skel/Desktop/Установить\ Zenith\ OS.desktop
EOF
chmod +x config/hooks/live/0500-zenith.hook.chroot

lb build 2>&1 | tee build.log
printf '\nISO готов: %s\n' "$(ls -1t live-image-*.hybrid.iso 2>/dev/null | head -n1)"
