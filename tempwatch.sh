#!/usr/bin/env bash

source /opt/hamawuebu/helper/hamawuebu.sh

ks_crit_max=8.0
ks_crit_min=4.0
ks_akt_unix_timestamp=$(date +"%s")

ks_t=$(/usr/bin/psql -qtA -U postgres -d fhemdb -c "select timestamp, value from fhem.history where reading = 'temperature' and type = 'LACROSSE' and device = 'LaCrosse_0C' order by timestamp DESC LIMIT 1;")

ks_dbvalue_timestamp=$(echo $ks_t | cut -f1 -d"|")
ks_dbvalue_unix_timestamp=$(date --date="$ks_dbvalue_timestamp" +"%s")
ks_dbvalue_temp=$(echo $ks_t | cut -f2 -d"|")

# Sind die Daten aus der DB juenger als 1h
ks_unix_timestamp_diff=$(echo "$ks_akt_unix_timestamp - $ks_dbvalue_unix_timestamp" | bc)
if [[ $ks_unix_timestamp_diff -gt 3600 ]]; then
	send_pushover "Kuehlschrank: DB Timestamp zu alt! $ks_dbvalue_timestamp"
fi

# Umweg ueber bc weil float
ks_bcrc=$(echo "$ks_dbvalue_temp >= $ks_crit_max" | bc)
ks_bcrc=$(echo "$ks_dbvalue_temp <= $ks_crit_min" | bc)
if [[ $ks_bcrc -gt 0 ]]; then
	#echo "Kühlschranktemperatur liegt uber dem Schwellwert ($ks_s)"
	send_pushover "Kuehlschrank: Schwellwert ueber/unterschreitung: $ks_dbvalue_temp Grad "
else
	# echo "Kühlschranktemperatur liegt unter dem Schwellwert ($ks_s)"
    # alles OK
    exit 0	
fi
