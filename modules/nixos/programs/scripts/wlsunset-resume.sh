#!/usr/bin/env bash

# Kill previous instance cleanly
pkill -x wlsunset || true

# HOUR=$(date +%H)
# if [ "$HOUR" -ge 20 ] || [ "$HOUR" -lt 8 ]; then
    # Start wlsunset in the background, disown to avoid zombie
    nohup wlsunset >/dev/null 2>&1 &
    disown
# fi
