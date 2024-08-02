#!/bin/bash

# install lowatch
sudo apt update
sudo apt install -y logwatch mailutils

# prepare email template and logwatch command, save as script
sudo mkdir -p /archive
sudo sh -c 'cat <<EOF >/archive/logwatch.sh
#!/bin/bash

logwatch --detail High --mailto '$USER' --service sshd xrdp vsftpd --range "between -3 days and today"
EOF'
sudo chmod +x /archive/logwatch.sh

# schedule cron job
if ! sudo crontab -l | grep -q '0 8 \* \* \* /archive/logwatch.sh'; then
  sudo crontab -l | {
    cat
    echo '0 8 * * * /archive/logwatch.sh'
  } | sudo crontab -
fi

# force run script, for screenshot
/archive/logwatch.sh

# check mail for screenshot
# mail
