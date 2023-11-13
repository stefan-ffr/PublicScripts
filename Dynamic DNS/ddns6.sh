#!/bin/bash
source /.env

# Check for current external IP
IP=`curl v6.ipinfo.io/ip`

# Set Cloudflare API
URL="https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID"
TOKEN="$TOKEN"
NAME="$FQDN"

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
