#!/bin/bash
#
# Cloudflare Dynamic DNS Update Script (IPv6)
# This script automatically updates your Cloudflare DNS record with your current IPv6 address
# Useful for home servers or dynamic IP connections
#

# Load environment variables from .env file
# The .env file should contain your Cloudflare API credentials:
#   ZONEID     - Your Cloudflare zone ID (found in domain overview)
#   RECORDID   - The DNS record ID to update (get via API or dashboard)
#   FQDN       - Fully Qualified Domain Name (e.g., subdomain.example.com)
#   TOKEN      - Cloudflare API token with DNS edit permissions
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please create one based on .env.example"
    exit 1
fi

# Get the current external IPv6 address of this machine
# Uses ipinfo.io service to determine public-facing IP
IP=`curl v6.ipinfo.io/ip`

# Construct the Cloudflare API endpoint URL
# This URL points to the specific DNS record we want to update
URL="https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records/${RECORDID}"
NAME="${FQDN}"

# Define a helper function to interact with the Cloudflare API
# Parameters: HTTP method (GET/PUT), optional data, optional extra arguments
# Uses Bearer token authentication for secure API access
cf() {
curl -X ${1} "${URL}" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${TOKEN}" \
      ${2} ${3}
}

# Query Cloudflare to get the current DNS record value
# This tells us what IP address is currently set in DNS
RESULT=$(cf GET)

# Extract the IP address from the JSON response
# jq is used to parse JSON and get the 'content' field (the current IP)
IP_CF=$(jq -r '.result.content' <<< ${RESULT})

# Compare the current external IP with the DNS record
if [ "$IP" = "$IP_CF" ]; then
    # IPs match - no update needed
    echo "No change."
else
    # IPs differ - update the DNS record with the new IP
    # Send PUT request with the new IP address as AAAA (IPv6) record
    RESULT=$(cf PUT --data "{\"type\":\"AAAA\",\"name\":\"${NAME}\",\"content\":\"${IP}\"}")
    echo "DNS updated."
fi
