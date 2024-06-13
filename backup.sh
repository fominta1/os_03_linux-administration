#!/bin/bash

# BACKUP SETUP SCRIPT

# create script
cat <<EOF >$HOME/backup.sh
cd /
tar cpf "/archive/backup-\$(date +%Y-%m-%d_%H%M%S).tar" --exclude="\$HOME/.*" /etc/ssh/sshd_config /etc/xrdp /etc/vsftpd.conf /etc/ssh/sshd_config /var/log "\$HOME"
EOF
sudo mkdir -p /archive
sudo mv $HOME/backup.sh /archive/

# create cron job
if ! sudo crontab -l | grep -q '30 18 \* \* 5 /archive/backup.sh';
	sudo crontab -l | {                                            
		cat                                                    
		echo '30 18 * * 5 /archive/backup.sh'             
	} | sudo crontab -                                             
fi                                                                     

# run script once for screenshot
sudo /archive/backup.sh

