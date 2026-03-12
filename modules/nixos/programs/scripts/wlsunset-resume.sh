#!/usr/bin/env bash

# Kill previous instance
pkill -x wlsunset || true

# HOUR=$(date +%H)
# if [ "$HOUR" -ge 20 ] || [ "$HOUR" -lt 8 ]; then
    # Start wlsunset in the background
    nohup wlsunset >/dev/null 2>&1 &
    disown
# fi
