#!/usr/bin/env bash

source /opt/hamawuebu/helper/hamawuebu.sh
source /opt/hamawuebu/helper/datapoints

getData="<?xml version="1.0"?>
  <methodCall>
  <methodName>getValue</methodName>
    <params>
      <param><value><string>$HM_PMSW1_ID_Kuehlschrank:1</string></value></param>
      <param><value><string>STATE</string></value></param>
    </params>
</methodCall>"

RC=$( curl -s --data "$getData" http://192.168.2.12:2001 | xml_grep 'boolean' - --text_only )

if [[ "$RC" != "1" ]]; then
	# Unklarer Status oder PMSw1 Ks AUS
	send_pushover "NETZSPANNUNGS ALARM Kuehlschrank: PMSw1 AUS!"
fi

