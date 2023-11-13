Place the ddns.sh or ddns6.sh file under your prefered directory, I'm recommend /usr/local/bin.

Use crontab -e as root or any other user you like and create following line to execute it regularly 
* * * * * /usr/local/bin/ddns > /dev/null 2>&1
