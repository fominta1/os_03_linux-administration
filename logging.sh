#!/bin/bash

# install lowatch
sudo apt update
sudo apt install -y logwatch mailutils

sudo cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
Output = mail
MailTo = fominta1@mydomain.org
MailFrom = logwatch@host1.mydomain.org
Detail = Low
Service = All


# prepare email template and logwatch command, save as script
cat <<EOF >$HOME/logwatch.sh
logwatch --detail Med --mailto root --service all --range today
EOF
sudo mkdir -p /archive
sudo mv $HOME/logwatch.sh /archive/
sudo chmod +x /archive/logwatch.sh

# schedule chron job
if ! sudo crontab -l | grep -q '0 8 \* \* \* /archive/logwatch.sh'; then 
	sudo crontab -l | {                                                  
		cat                                                          
		echo '0 8 * * * /archive/logwatch.sh'                   
	} | sudo crontab -                                                   
fi                                                                           

# force run script for screenshot
/archive/logwatch.sh

# check mail for screenshot
# sudo mail
