#!/bin/bash

sleep 5m

/usr/local/aeris_lib/scripts/load-initial-device-cache.sh &
/usr/local/aeris_lib/scripts/load-alert-cache.sh &
/usr/local/aeris_lib/scripts/load-country-codes.sh &
/usr/local/aeris_lib/scripts/load-event-stream.sh &
/usr/local/aeris_lib/scripts/load-point-code-carrier.sh &
/usr/local/aeris_lib/scripts/load-rate-plan-map.sh &
/usr/local/aeris_lib/scripts/load-alert-cache.sh &
/usr/local/aeris_lib/scripts/load-current-value.sh &
/usr/local/aeris_lib/scripts/load-defaulting-cache.sh &
