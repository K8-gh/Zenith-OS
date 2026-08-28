#!/usr/bin/env bash
set -Eeuo pipefail
OUT=/home/ubuntu/np300e5x-win10/docs/apps-check.txt
BASE=/home/ubuntu/np300e5x-win10
{
  echo 'ПРОВЕРКА СОСТАВА ПРИЛОЖЕНИЙ'
  echo "Дата: $(date -u +%F' '%TZ)"
  echo
  echo 'Заявленные установочные пакеты:'
  awk '/^sudo apt-get install -y \\/,/^$/{print}' "$BASE/scripts/install-np300e5x.sh" | sed -n '2,99p' | sed 's/[\\ ]//g' | tr '\\n' ' ' || true
  echo
  echo
  echo 'Приложения, которые устанавливаются скриптом:'
  printf '%s\n' 'Firefox ESR (русский пакет), VLC, Synaptic, GDebi, Timeshift, Gufw, Blueman, Pavucontrol, system-config-printer, Simple Scan, htop, inxi, Powertop, hide.me VPN.'
  echo
  echo 'Приложения только отображаются в UI-макете, но не являются установленными в песочнице:'
  printf '%s\n' 'Проводник файлов, Firefox ESR, Synaptic, hide.me VPN, VLC, Центр управления.'
  echo
  echo 'Тест загрузки дополнительного пакета:'
  TMP=$(mktemp -d)
  if (cd "$TMP" && apt-get download htop >/tmp/np300e5x-apt-download.log 2>&1); then
    ls -lh "$TMP"/*.deb
    sha256sum "$TMP"/*.deb
    echo 'Результат: архив htop скачан для проверки, но не установлен.'
  else
    cat /tmp/np300e5x-apt-download.log || true
    echo 'Результат: загрузка тестового пакета не выполнена в текущей Ubuntu-песочнице; это не означает проблему в Debian ISO.'
  fi
  rm -rf "$TMP"
} > "$OUT"
cat "$OUT"
