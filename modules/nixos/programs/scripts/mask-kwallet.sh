#!/usr/bin/env bash
mkdir -p ~/.local/share/dbus-1/services

echo -e "[D-BUS Service]\nName=org.kde.kwalletd\nExec=/bin/false" > ~/.local/share/dbus-1/services/org.kde.kwalletd.service
echo -e "[D-BUS Service]\nName=org.kde.kwalletd5\nExec=/bin/false" > ~/.local/share/dbus-1/services/org.kde.kwalletd5.service
echo -e "[D-BUS Service]\nName=org.kde.kwalletd6\nExec=/bin/false" > ~/.local/share/dbus-1/services/org.kde.kwalletd6.service
