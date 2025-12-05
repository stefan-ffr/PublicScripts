Place the ddns.sh (IPV4 A Record) or ddns6.sh (IPV6 AAAA Record) file under your prefered directory, I'm recommend /usr/local/bin.

Use crontab -e as root or any other user you like and create following line to execute it regularly 

[* * * * * /usr/local/bin/ddns.sh > /dev/null 2>&1]

[* * * * * /usr/local/bin/ddns6.sh > /dev/null 2>&1]
