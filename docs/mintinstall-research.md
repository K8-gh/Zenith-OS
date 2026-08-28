# Проверка mintinstall 8.4.0

Официальный индекс Linux Mint показывает mintinstall 8.4.0 как пакет архитектуры all для ветки zena: http://packages.linuxmint.com/search.php?release=any&section=any&keyword=mintinstall

Проверенный control-файл пакета mintinstall 8.4.0 содержит зависимости python3, python3-bs4, python3-gi-cairo, python3-lxml, python3-setproctitle, python3-xapp, gir1.2-gdkpixbuf-2.0, gir1.2-glib-2.0, gir1.2-gtk-3.0, gir1.2-xapp-1.0, libgtk3-perl, mint-common >= 2.2.4 и app-install-data; рекомендуются gir1.2-flatpak-1.0, flatpak и xdg-desktop-portal-gtk.

Исходный код и инструкция сборки находятся в официальном репозитории: https://github.com/linuxmint/mintinstall

Официальная проблема #423 описывает зависание на «generating cache»; в обсуждении указано, что отсутствие Flatpak remote может приводить к циклической генерации кэша: https://github.com/linuxmint/mintinstall/issues/423

Решение для Zenith OS: не подключать репозитории Linux Mint для системных пакетов Debian. Если mintinstall 8.4.0 устанавливается, использовать локальный пакет и проверять зависимости; заранее добавить Flathub, включить timeout на обновление AppStream/Flatpak, очищать повреждённый пользовательский кэш и показывать ошибку вместо бесконечного ожидания. Основным резервным менеджером оставить GNOME Software/Synaptic.
