# Adblocker Configuration

Configuration files for ad-blocking applications.

## Files

### lists/allow.txt

Whitelist/allowlist for domains that should not be blocked by your ad blocker.

## Usage

Import the allow list into your ad-blocking solution:
- **Pi-hole**: Settings → Whitelist → Import
- **AdGuard Home**: Filters → Custom filtering rules
- **Browser extensions**: Varies by extension

## Customization

Edit `lists/allow.txt` to add domains you want to whitelist:
```
example.com
subdomain.example.com
```

One domain per line, no wildcards needed.
