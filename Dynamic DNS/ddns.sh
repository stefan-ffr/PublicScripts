#!/bin/bash

# Check for current external IP
IP=`curl v6.ipinfo.io/ip`

# Set Cloudflare API
URL="https://api.cloudflare.com/client/v4/zones/215ddf1f01bb8053e0cc9bdeaa924435/dns_records/f83496903da698853074223888ad8337"
TOKEN="CdHdo8fSjsmoTOUEn4ztYTzzSvC1Ly8M11ENDs5s"
NAME="r9laptop.ip.juroct.net"

# Connect to Cloudflare
cf() {
curl -X ${1} "${URL}" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
      ${2} ${3}
}

# Get current DNS data
RESULT=$(cf GET)
IP_CF=$(jq -r '.result.content' <<< ${RESULT})

# Compare IPs
if [ "$IP" = "$IP_CF" ]; then
    echo "No change."
else
    RESULT=$(cf PUT --data "{\"type\":\"AAAA\",\"name\":\"${NAME}\",\"content\":\"${IP}\"}")
    echo "DNS updated."
fi
