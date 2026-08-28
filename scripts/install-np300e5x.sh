#!/usr/bin/env bash
set -Eeuo pipefail

# Zenith OS setup for Samsung NP300E5X
# Intended for Debian 13 (trixie) amd64 with Xfce.
# Run from a TTY or terminal as a normal user; sudo is used only where needed.

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Запускайте этот скрипт обычным пользователем, не root."
  exit 1
fi

sudo -v
export DEBIAN_FRONTEND=noninteractive
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/np300e5x-backup-$STAMP"
mkdir -p "$BACKUP"

sudo cp -a /etc/apt/sources.list.d "$BACKUP/" 2>/dev/null || true
cp -a "$HOME/.config/xfce4" "$BACKUP/" 2>/dev/null || true

# Enable the firmware component required by many Wi-Fi/Bluetooth devices.
if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
  sudo sed -i -E 's/^Components:.*$/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources
elif [[ -f /etc/apt/sources.list ]]; then
  sudo sed -i -E 's/ main( contrib)?( non-free)?( non-free-firmware)?$/ main contrib non-free non-free-firmware/' /etc/apt/sources.list
fi

sudo apt-get update
sudo apt-get install -y \
  task-xfce-desktop lightdm lightdm-gtk-greeter calamares os-prober debian-installer-launcher \
  xfce4-settings xfce4-terminal xfce4-panel thunar xfce4-whiskermenu-plugin menulibre \
  xfce4-goodies xfce4-appfinder xfce4-session xfce4-workspaces xfce4-power-manager \
  xfce4-pulseaudio-plugin xfce4-notifyd xfce4-clipman xfce4-clipman-plugin \
  firefox-esr firefox-esr-l10n-ru \
  network-manager network-manager-gnome modemmanager \
  bluez blueman rfkill \
  firmware-linux firmware-linux-nonfree firmware-atheros firmware-iwlwifi \
  firmware-realtek firmware-brcm80211 \
  mesa-utils mesa-vulkan-drivers xserver-xorg-video-intel \
  pavucontrol pipewire pipewire-pulse wireplumber \
  cups system-config-printer simple-scan \
  gufw synaptic gdebi timeshift \
  gnome-software gnome-software-plugin-flatpak flatpak xdg-desktop-portal-gtk \
  default-jre libreoffice libreoffice-l10n-ru gimp inkscape audacity \
  mousepad ristretto galculator xfce4-screenshooter xfce4-taskmanager catfish \
  network-manager-openvpn network-manager-openconnect \
  file-roller gparted baobab exfatprogs ntfs-3g hplip remmina transmission-gtk \
  thunderbird thunderbird-l10n-ru \
  aisleriot gnome-mines gnome-sudoku neverball supertux frozen-bubble \
  unzip p7zip-full curl wget git vlc ffmpeg wireguard-tools python3 python3-tk \
  thermald tlp powertop htop inxi lm-sensors \
  fonts-liberation fonts-noto-core fonts-noto-cjk \
  synaptic

sudo apt-get install -y locales task-russian || true

# Official Flatpak sources and launchers for the Minecraft launchers.
# Flatpak keeps these applications isolated from the Debian base system.
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
sudo flatpak install -y flathub org.prismlauncher.PrismLauncher || true
ELY_REF="$(mktemp --suffix=.flatpakref)"
if curl -fsSL https://elyprismlauncher.github.io/flatpak/elyprismlauncher.flatpakref -o "$ELY_REF"; then
  sudo flatpak install -y "$ELY_REF" || true
fi
rm -f "$ELY_REF"
sudo sed -i 's/^# *ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=ru_RU.UTF-8 LANGUAGE=ru_RU:ru LC_ALL=ru_RU.UTF-8

# Keep Intel as the safe default. Nouveau remains available for the old GT 620M;
# no fragile proprietary legacy NVIDIA module is forced into the initial install.
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable cups
sudo systemctl enable lightdm
sudo systemctl enable tlp || true
sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null || true

# Install the latest official hide.me Linux CLI release for amd64.
# The binary is fetched only from the official GitHub repository and the release
# API determines the current version, so the ISO is not stuck with an old build.
HIDE_DIR="$(mktemp -d)"
python3 - "$HIDE_DIR" <<'PY'
import json, pathlib, sys, urllib.request
out = pathlib.Path(sys.argv[1])
api = urllib.request.Request(
    'https://api.github.com/repos/eventure/hide.client.linux/releases/latest',
    headers={'Accept': 'application/vnd.github+json', 'User-Agent': 'np300e5x-debian-builder'}
)
with urllib.request.urlopen(api, timeout=30) as r:
    release = json.load(r)
assets = [a for a in release.get('assets', []) if 'linux-amd64' in a.get('name', '')]
if not assets:
    raise SystemExit('Не найден amd64-архив hide.me в последнем официальном релизе')
asset = assets[0]
archive = out / asset['name']
urllib.request.urlretrieve(asset['browser_download_url'], archive)
(out / 'version').write_text(release.get('tag_name', 'unknown'))
(out / 'archive').write_text(str(archive))
PY
HIDE_ARCHIVE="$(cat "$HIDE_DIR/archive")"
sudo mkdir -p /opt/hide.me
sudo tar -xzf "$HIDE_ARCHIVE" -C /opt/hide.me
if [[ -x /opt/hide.me/install.sh ]]; then
  sudo /opt/hide.me/install.sh || true
fi
sudo cp -f /opt/hide.me/hide.me /usr/local/bin/hide.me 2>/dev/null || true
sudo chmod +x /usr/local/bin/hide.me 2>/dev/null || true
sudo cp -f /opt/hide.me/hide.me@.service /etc/systemd/system/ 2>/dev/null || true
sudo systemctl daemon-reload
cat > "$HOME/.local/share/applications/hide-me-vpn.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=hide.me VPN
Name[ru]=hide.me VPN
Comment=Официальный WireGuard-клиент hide.me
Exec=xfce4-terminal --title="hide.me VPN" -e /usr/local/bin/hide.me
Icon=network-vpn
Terminal=false
Categories=Network;Security;
EOF
rm -rf "$HIDE_DIR"

# Apply conservative power settings for this older notebook.
sudo mkdir -p /etc/np300e5x
sudo tee /etc/np300e5x/README > /dev/null <<'EOF'
Default graphics policy: Intel i915 is preferred for reliability. The NVIDIA GT 620M is not forced on at boot.
If external display or 3D acceleration is needed, test nouveau first; create a restore point before any proprietary legacy driver experiment.
EOF

# Xfce profile with a familiar Windows-like layout.
mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -s Papirus 2>/dev/null || true
xfconf-query -c xsettings -p /Gtk/FontName -s 'Noto Sans 10' 2>/dev/null || true
xfconf-query -c xfwm4 -p /general/theme -s Default 2>/dev/null || true
xfconf-query -c xfwm4 -p /general/title_font -s 'Noto Sans Bold 10' 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/position -s 'p=8;x=0;y=0' 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/length -s 100 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 38 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/autohide -s false 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 0 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s true 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s true 2>/dev/null || true

# Install the GitHub Release updater.
UPDATER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../updater/package" 2>/dev/null && pwd)"
if [[ -f "$UPDATER_DIR/install.sh" ]]; then
  sudo bash "$UPDATER_DIR/install.sh"
fi

# Add user-facing launchers for the application center and settings.
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/np300e5x-app-center.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Центр приложений
Comment=Установка и обновление программ из Debian и Flatpak
Exec=gnome-software
Icon=gnome-software
Terminal=false
  Categories=System;PackageManager;
EOF
cat > "$HOME/.local/share/applications/np300e5x-prism.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Prism Launcher
Comment=Менеджер сборок Minecraft
Exec=flatpak run org.prismlauncher.PrismLauncher
Icon=org.prismlauncher.PrismLauncher
Terminal=false
Categories=Game;
EOF
cat > "$HOME/.local/share/applications/np300e5x-elyprism.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=PineconeMC / ElyPrism
Comment=Лаунчер Minecraft с поддержкой Ely.by
Exec=flatpak run org.elyprismlauncher.Launcher
Icon=org.elyprismlauncher.Launcher
Terminal=false
Categories=Game;
EOF

cat > "$HOME/.local/share/applications/np300e5x-desktop-settings.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Настройки рабочего стола
Comment=Панель, темы, обои, значки и окна Xfce
Exec=xfce4-settings-manager
Icon=preferences-desktop
Terminal=false
Categories=Settings;DesktopSettings;
EOF
cat > "$HOME/.local/share/applications/np300e5x-os-settings.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Настройки ОС
Comment=Сеть, Bluetooth, звук, экран, питание и безопасность
Exec=xfce4-settings-manager
Icon=preferences-system
Terminal=false
Categories=Settings;System;
EOF

# Make Firefox the default browser and add a first-login help document.
xdg-settings set default-web-browser firefox-esr.desktop 2>/dev/null || true
mkdir -p "$HOME/Desktop"
cat > "$HOME/Desktop/Первые шаги в Zenith OS.md" <<'EOF'
# Первые шаги в Zenith OS

1. Нажмите значок сети справа на панели для Wi-Fi.
2. Значок Bluetooth открывает Blueman: включите адаптер и добавьте устройство.
3. «Меню» → «Настройки» содержит экран, звук, питание, принтеры и firewall.
4. Firefox находится в меню «Интернет».
5. Timeshift создаёт снимки системы перед крупными изменениями.
6. Для диагностики откройте терминал и выполните `inxi -Fxxxz`.
EOF

sudo update-initramfs -u -k all
sudo systemctl set-default graphical.target
printf '\nГотово. Перезагрузите компьютер командой: sudo reboot\nРезервная копия конфигурации: %s\n' "$BACKUP"
printf 'Проверка после перезагрузки: inxi -Fxxxz ; rfkill list ; systemctl --failed\n'
