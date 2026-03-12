#!/usr/bin/env bash

HOUR=$(date +%H)
if [ "$HOUR" -ge 16 ] || [ "$HOUR" -lt 8 ]; then
    nohup wlsunset >/dev/null 2>&1 &
    disown
fi
