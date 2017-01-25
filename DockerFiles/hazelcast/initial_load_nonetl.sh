#!/bin/bash

sleep 5m

/usr/local/aeris_lib/scripts/load-initlial-sub-id-list.sh &
/usr/local/aeris_lib/scripts/load-alert-cache.sh &
/usr/local/aeris_lib/scripts/load-aercloud-apikeys.sh &
/usr/local/aeris_lib/scripts/mcc-to-zone-maps.sh &
/usr/local/aeris_lib/scripts/nas-ip-cache-load.sh &
/usr/local/aeris_lib/scripts/load-alert-cache.sh &
/usr/local/aeris_lib/scripts/load-current-value.sh &
/usr/local/aeris_lib/scripts/load-daily-usage-counts.sh &
