#!/bin/bash

. /etc/os-release

# check backports

if grep -q 'deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse' /etc/apt/sources.list; then
	echo backports is enabled already
else
	echo 'deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse' >> /etc/apt/sources.list
fi

# update & install apache + ssh + python

sudo apt update && sudo apt upgrade -y
sudo apt install -y ssh apache2 python3-{pip,venv} curl

# enable ssh and apache

sudo systemctl enable --now apache2
sudo systemctl enable --now sshd

# additional 5 points
# 1. create backup user for next task
sudo useradd backup
# 2. enabling rdp and installing GUI
sudo apt install -y xfce4 xrdp
echo xfce4-session >$HOME/.xsession
# 3. create custom ~/.bashrc
cat <<'EOF' >>$HOME/.bashrc
alias ll='ls -lh'
alias la='ll -A'
EOF
source $HOME/.bashrc

# 4. curl ifconfig.co > to log

# making script
sudo mkdir /opt
cat <<'EOF' >$HOME/getip.sh
echo $(date +%Y-%m-%d_%H%M%S) > /archive/iplog.txt
curl ifconfig.co >> /archive/iplog.txt
EOF
sudo mv $HOME/getip.sh /opt
sudo chmod +x /opt/getip.sh

# making cronjob to run script
if ! sudo crontab -l | grep -q '30 18 \* \* 5 /opt/getip.sh'; then 
	sudo crontab -l | {                                                  
		cat                                                          
		echo '30 18 * * 5 /opt/getip.sh'                   
	} | sudo crontab -                                                   
fi                                                                           

# 5. install lazygit
if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit /usr/local/bin
elif [ "$ID" = "fedora" ]; then
	sudo dnf copr enable atim/lazygit -y
	sudo dnf install -y lazygit
elif [ "$ID_LIKE" = "arch" ]; then
    sudo pacman -Sy lazygit
fi
