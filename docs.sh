#* install barrier: 
    sudo apt install barrier. then disable ssl to make it works
#* Install Inputleaf
    sudo apt-get update
    sudo apt-get install libqt6core6t64 libqt6gui6 libqt6network6 libqt6widgets6
    sudo dpkg -i InputLeap_3.0.2_debian12_amd64.deb #! Download from the website
    #! Open port 24800 to use barrier:
    sudo ufw allow 24800/tcp
    sudo ufw delete allow 24800/tcp #! Delete the rule
    sudo ufw allow from 192.168.1.5 to any port 24800 #! Allow from 1 specific IP
#* Install ibus-bamboo (unikey on linux)
    sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo
    sudo apt-get update
    sudo apt-get install ibus ibus-bamboo --install-recommends
    ibus restart
    # Đặt ibus-bamboo làm bộ gõ mặc định
    env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"
#* make f1-f12 key works: 
    sudo sh -c 'echo 2 > /sys/module/hid_apple/parameters/fnmode'
    sudo nano /etc/systemd/system/set-fnmode.service
    sudo systemctl daemon-reload
    sudo systemctl enable set-fnmode.service
    sudo systemctl start set-fnmode.service
#* fix brave: 
    cd ~/.config/BraveSoftware/Brave-Browser
    rm ~/.config/BraveSoftware/Brave-Browser/SingletonSocket
    rm ~/.config/BraveSoftware/Brave-Browser/SingletonLock
#* Install HyperHDR for backlight led:
    sudo apt remove hyperhdr
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://awawa-dev.github.io/hyperhdr.public.apt.gpg.key | sudo dd of=/usr/share/keyrings/hyperhdr.public.apt.gpg.key \
    && sudo chmod go+r /usr/share/keyrings/hyperhdr.public.apt.gpg.key \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hyperhdr.public.apt.gpg.key] https://awawa-dev.github.io $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hyperhdr.list > /dev/null \
    && sudo apt update \
    && sudo apt install hyperhdr -y
#* Add user in HyperHDR:
    sudo usermod -a -G dialout $USER
    # Replace /dev/ttyUSB0 with your actual device path
    sudo chmod 666 /dev/ttyUSB0
    sudo nano /etc/udev/rules.d/99-hyperion.rules
    # Add this line
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="dialout"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
#* Change screen brightness:
    1). Open /etc/default/grub in a text editor with sudo permissions 
    for example sudoedit /etc/default/grub
    2). Add amdgpu.backlight=0 to the line GRUB_CMDLINE_LINUX="..."
    2). Run sudo update-grub
    3). Reboot
#* install Jetbrains Mono fonts:
    cd /home/hankel/Downloads/JetBrainsMono-2.304/fonts/ttf
    sudo cp *.ttf /usr/share/fonts/truetype/
    sudo fc-cache -f -v
#* install gcloud
    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates gnupg curl
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt-get update && sudo apt-get install google-cloud-cli
    gcloud init
    gcloud auth application-default login
#* install miniconda:
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    sha256sum Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
    source ~/.bashrc
    conda create --name freqtrade python=3.12 --file requirements.txt
#* change host name:
    sudo nano /etc/hostname
    sudo nano /etc/hosts
    sudo hostnamectl set-hostname "new-hostname-here"
#* generate key pair for Binance:
    openssl genpkey -algorithm ed25519 -out private_key.pem
    openssl pkey -in private_key.pem -pubout -out public_key.pem
#* save api key and private key
#* check ipv4 - allow only whitelist IP:
    curl -4 ifconfig.me (113.190.146.149)
#* using hashicorp vault for storing api key and private key and other things (metamask recovery passphrase):
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install vault
#* using gpg for storing api key and private key and other things (metamask recovery passphrase):
    sudo apt update
    sudo apt install gnupg
    gpg --full-generate-key
    choose default options, set duration to 1 month
    gpg --list-keys
    gpg --encrypt --recipient <last 8 digit of the key> api_key.pem
    gpg --encrypt --recipient <last 8 digit of the key> private_key.pem
    gpg --encrypt --recipient <last 8 digit of the key> public_key.pem
    shred -u api_key.pem private_key.pem public_key.pem - delete old files
#* to use keys in python:
    pip install python-gnupg
#* Setting fixed ipv6 address
    curl -6 ifconfig.me #! Checking the IPv6 address (2001:ee0:4141:a241:744f:b885:9438:8a5)
    curl -6 https://icanhazip.com
    #! Then go to the network setting (wifi or wired network) and set the IPv6 to Manual, not automatic.
    #! Then set the above address, with the prefix=64.
    #! Leave others blank for now.
#! Setting fixed ipv4 address
    cd /etc/netplan
    sudo nano 01-network-manager-all.yaml
    # network:
    # version: 2
    # renderer: NetworkManager
    # ethernets: 
    #     wlxe0ad4730b132: #? use ip a to check the name of the network
    #     dhcp4: no
    #     addresses: [192.168.1.2/24] #? the ip we want to set
    #     routes:
    #         - to: default
    #         via: 192.168.1.1
    #     nameservers:
    #         addresses: [123.23.23.23, 123.26.26.26] #? the DNS of the wifi, view in the wifi setting
    sudo netplan try
    sudo netplan apply
    
#* open ping for the remote EC2 instance:
    sudo iptables -P INPUT DROP
    sudo iptables -P OUTPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -A INPUT -s 46.137.199.58 -p ICMP --icmp-type 8 -j ACCEPT
    sudo iptables -A OUTPUT -d 46.137.199.58 -p icmp --icmp-type 8 -j ACCEPT
    sudo iptables -A INPUT -s 46.137.199.58 -p icmp --icmp-type echo-request -j ACCEPT
    sudo iptables -A OUTPUT -d 46.137.199.58 -p icmp --icmp-type echo-reply -j ACCEPT
    sudo iptables -A INPUT -p ICMP --icmp-type 8 -j DROP
    sudo iptables-save #! Dangerous command
    -A ufw-before-input -p icmp --icmp-type 8 echo-request -s 46.137.199.58 -m state --state ESTABLISHED -j ACCEPT
#* checking current rules of the iptables:
    sudo iptables -L -v -n

Hello,

Enabling IPv6 on an existing EC2 instance involves several key steps.

Here is a step-by-step guide to enabling IPv6 on an existing EC2 instance and establishing an SSH connection using IPv6:

Enable IPv6 in VPC Settings: Start by adding a new IPv6 CIDR to your Virtual Private Cloud (VPC).
Add IPv6 Subnet to EC2 Subnet: Identify the subnet where your EC2 instance is located and add an IPv6 subnet to it (Action --> Edit IPv6 CIDRs --> Add IPv6 CIDR).
Assign IPv6 Address: Associate an IPv6 address with your EC2 instance using either the AWS Management Console (Actions --> Networking --> Manage IP Addresses --> Add IPv6) or the AWS CLI.
Add IPv6 Default Route to Subnet Routing Table with IGW Destination: Update the routing table associated with the subnet to include a default route for IPv6 with the Internet Gateway (IGW) as the destination.
    In the VPC Dashboard, click on Route Tables in the left sidebar.

    Select the route table that’s associated with your subnet.

    Click Edit routes, then click Add route.

    For the Destination, enter ::/0 (this represents the entire IPv6 address space).

    For the Target, select your Internet Gateway.

    Click Save routes.
Update Security Group: Modify the security group linked to your EC2 instance to permit incoming IPv6 traffic on the SSH port (default is 22). If there is no existing inbound rule for IPv6, create one."That will expose the internet to the internet so Try to Limit the Source in the Security Group"
SSH Connection: With IPv6 now enabled, use the assigned IPv6 address to establish an SSH connection to your EC2 instance.



daoduydai.com is not active on Cloudflare yet
Update the nameservers at your registrar to activate Cloudflare services for this domain.

This process makes Cloudflare your authoritative DNS provider, allowing your DNS queries and web traffic to be served from and protected by our global network.

In most cases, this process will not cause downtime, but you may skip this for now to double-check 
your DNS records
 and pre-configure other settings before activating (you can find these instructions again later on the 
Overview
 page).

Log in to the domain registrar or reseller where you registered the parent domain
Find your registrar on ICANN WHOIS

Avoid DNS resolution issues caused by DNSSEC
Find the DNSSEC setting at your registrar (per-provider instructions). If it is on, you have two options:

Turn DNSSEC off at least 24 hours before updating your nameservers. Most common
Migrate your existing DNS zone without turning off DNSSEC. More advanced
After your domain activates, we recommend 
turning DNSSEC on
 through Cloudflare.

Update your nameservers
Find the list of nameservers at your registrar. Add both of your assigned Cloudflare nameservers, remove any other nameservers, and save your changes.


Your assigned Cloudflare nameservers:

alaric.ns.cloudflare.com
Click to copy
tess.ns.cloudflare.com
Click to copy
Registrars take up to 24 hours to process nameserver changes (quicker in most cases). We will email you when daoduydai.com is active on Cloudflare.

While in this pending state, Cloudflare will respond to DNS queries on your assigned nameservers.

Once activated, SSL/TLS, DDoS protection, caching, and other automatic optimizations will go live for proxied DNS records, along with any custom settings you pre-configure.

Learn more about pending domains

Cloudflare will periodically check for nameserver updates.


Need help? Follow our 
set-up documentation
 or 
visit our support portal
.

Were these instructions clear? 
Give feedback


#! Reinstall network-manager
sudo mount /dev/nvme0n1p5 /mnt #? replace nvme0n1p5 with the partition contains ubuntu
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt
nano /etc/resolv.conf
#? In the open file, add OpenDNS name servers
nameserver 123.23.23.23
nameserver 123.26.26.26

apt-get install --reinstall network-manager

#! Temparature monitor
sudo apt-get install lm-sensors 
sudo sensors-detect
sensors

#! Install OpenSSH Server
sudo apt install openssh-server
sudo systemctl status ssh
sudo systemctl start ssh
sudo systemctl enable ssh
sudo ufw allow ssh # Config firewall

#! docker desktop
sudo apt install gnome-terminal
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce-cli
wget https://desktop.docker.com/linux/main/amd64/175267/docker-desktop-amd64.deb
sudo apt-get install ./docker-desktop-amd64.deb
sudo systemctl --user start docker-desktop
sudo docker run hello-world
#? Make docker auto startup
To enable Docker Desktop to start on sign in, from the Docker menu, select Settings > General > Start Docker Desktop when you sign in to your computer

#? To login Docker
gpg --generate-key
pass init B2F4F4496EC45F019A8AC211D02B7D7BAB9DD740

# #! open port 8989
# sudo apt update
# sudo apt install wireguard
# wg genkey | tee privatekey | wg pubkey > publickey
# wg genpsk > presharedkey
# nano /etc/wireguard/wg0.conf
# [Interface]
# PrivateKey = <Home-PrivateKey>   #? Private key for the home machine (keep this secret). MDncO9iF07bxQpg8qBM5j3dK7iGdqShzttCS/ukg80U=
# Address = 10.0.0.2/24            #? IP assigned to the home machine within the WireGuard VPN.

# [Peer]
# PublicKey = <EC2-PublicKey>      #? Public key of the EC2 WireGuard server. 8ubimYCxhyfZXz5gr8YVgdc/RBGwOiPRpSLIdXEAV0M=
# Endpoint = x:51820               #? Public IP (or DNS) of the EC2 server and WireGuard port.
# AllowedIPs = 10.13.13.1/32         #? Traffic destined for this range is routed through the VPN.
# PersistentKeepalive = 25         #? Ensures the connection stays active (useful for NAT setups).
# sudo wg-quick up wg0
# sudo sysctl -w net.ipv4.ip_forward=1 #? Enable IP forwarding temporarily
# echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf #? Enable IP forwarding permanently
# sudo iptables -t nat -A PREROUTING -i wg0 -p tcp --dport 8989 -j DNAT --to-destination 127.0.0.1:8989
# sudo iptables -A FORWARD -p tcp -d 127.0.0.1 --dport 8989 -j ACCEPT
# sudo iptables -A FORWARD -p tcp -d 127.0.0.1 --dport 8989 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# sudo wg-quick down wg0 && sudo wg-quick up wg0

# sudo apt install net-tools
# sudo netstat -tuln | grep 8989

#! Add Cloudflare tunnels
#? Check this: https://www.youtube.com/watch?v=ey4u7OUAF3c&t=477s
docker run -d\
	--name cloudflare_tunnel\
	--restart unless-stopped cloudflare/cloudflared:latest tunnel\
	--no-autoupdate run\
	--token $CLOUDFLARE_TUNNEL_TOKEN
docker update --restart always

#! freqtrade
mkdir ft_userdata
cd ft_userdata/
# Download the docker-compose file from the repository
curl https://raw.githubusercontent.com/freqtrade/freqtrade/stable/docker-compose.yml -o docker-compose.yml

# Pull the freqtrade image
docker compose pull

# Create user directory structure
docker compose run --rm freqtrade create-userdir --userdir user_data

# Create configuration - Requires answering interactive questions
docker compose run --rm freqtrade new-config --config user_data/config.json

#! install freqtrade repo
sudo apt install python3-pip
# Download `develop` branch of freqtrade repository
git clone https://github.com/freqtrade/freqtrade.git

# Enter downloaded directory
cd freqtrade

# your choice (1): novice user
git checkout stable

# your choice (2): advanced user
git checkout develop

# Install TA-Lib
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar xvzf ta-lib-0.4.0-src.tar.gz
cd ta-lib
sed -i.bak "s|0.00000001|0.000000000000000001 |g" src/ta_func/ta_utility.h
./configure --prefix=/usr/local
make
sudo make install
# On debian based systems (debian, ubuntu, ...) - updating ldconfig might be necessary.
sudo ldconfig  
cd ..
rm -rf ./ta-lib*
sudo ./build_helpers/install_ta-lib.sh

# # --install, Install freqtrade from scratch
# ./setup.sh -i

# # --update, Command git pull to update.
# ./setup.sh -u
# # --reset, Hard reset your develop/stable branch.
# ./setup.sh -r

conda create --name freqtrade python=3.12

python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
python3 -m pip install -e .

cd build_helpers
bash install_ta-lib.sh ${CONDA_PREFIX} nosudo

#! Generate requirements.txt file
pip freeze > requirements.txt


#! WHEN DOING ANYTHING WITH THE BOT, REMEMBER TO CD INTO ft_userdata/ FIRST

#! Config the bot
# Step 1 - Initialize user folder
freqtrade create-userdir --userdir user_data

# Step 2 - Create a new configuration file
freqtrade new-config --config user_data/config.json

#! Use .env file to store sensitive information
chmod 600 .env
if [ -f .env ]; then
	while IFS= read -r line; do
		# Skip comments and empty lines
		if [[ ! "$line" =~ ^# ]] && [[ -n "$line" ]]; then
		# Remove inline comments
		line=$(echo "$line" | sed 's/\s*#.*//')
		# Export the variable
		export "$line"
		# Echo the exported variable
		echo "Exported: $line"
		fi
	done < .env
fi

#! Add this config to the end of the config.json file
"user_data_dir": "/home/hankniel/works/crypto/ft_userdata/user_data/"

#! Show final config
freqtrade show-config --config user_data/configs/config.json

#! Test Pairlist
freqtrade test-pairlist --config user_data/configs/config.json

#! Download Data
cd ft_userdata/
#* Download 1 pair
freqtrade download-data \
	--config user_data/configs/config.json \
	--timerange 20241101- \
	--timeframes 1m \
	--pairs BTC/USDT:USDT

#* Download all pairs
freqtrade download-data --config user_data/configs/config.json --timerange 20241101-

#* Download data with configs
freqtrade download-data \
	--config user_data/configs/config.json \
	--timerange 20241101- \
	--timeframes 1m 5m \
	--trading-mode futures \
	--verbose -v \
	--logfile /home/hankniel/works/crypto/ft_userdata/user_data/logs/download_data.log \
	--datadir /home/hankniel/works/crypto/ft_userdata/user_data/data/binance/ \
	--erase

freqtrade list-data --config user_data/configs/config.json \
	--show-timerange \
	--verbose -v \
	--trading-mode futures \
	--logfile /home/hankniel/works/crypto/ft_userdata/user_data/logs/list_data.log \
	--datadir /home/hankniel/works/crypto/ft_userdata/user_data/data/binance/

#! Download data auto
cd ft_userdata/user_data/tools/
chmod +x update_data.sh
./update_data.sh
# Schedule data downloading job
crontab -e 
# config to download new data every 4 hours
0 */4 * * * /home/hankniel/works/crypto/ft_userdata/user_data/tools/update_data.sh

#! Backtesting
freqtrade backtesting \
	--config user_data/configs/config.json \
	--verbose -v \
	--timerange 20241101-20250130 \
	--timeframe 5m \
	--dry-run-wallet 1000 \
	--strategy-list NASOSv4 \
	--export trades \
	--logfile /home/hankniel/works/crypto/ft_userdata/user_data/logs/backtesting.log \
	--datadir /home/hankniel/works/crypto/ft_userdata/user_data/data/binance/

#! Backtest Analysis
freqtrade backtesting-analysis \
	--config user_data/configs/config.json \
	--export-filename 
	--analysis-groups 0 1 2 3 4 5

#! Hyperopt
freqtrade hyperopt \
	--config user_data/configs/config.json \
	--strategy NostalgiaForInfinityX4 \
	--job-workers -3 \
	--random-state 42 \
	--hyperopt HyperOptHyperopt \
	--hyperopt-loss SharpeHyperOptLossDaily \
	--spaces all \
	--export trades \
	--logfile /home/hankniel/works/crypto/ft_userdata/user_data/logs/hyperopt.log \
	--datadir /home/hankniel/works/crypto/ft_userdata/user_data/data/binance/

#! Quickly hyperopt roi, stoploss and trailing spaces without modifying the strategy
freqtrade hyperopt \
	--hyperopt-loss SharpeHyperOptLossDaily \
	--spaces roi stoploss trailing \
	--strategy NostalgiaForInfinityX4 \
	--job-workers -3 \
	--config user_data/configs/config.json \
	--logfile /home/hankniel/works/crypto/ft_userdata/user_data/logs/hyperopt.log \
	--datadir /home/hankniel/works/crypto/ft_userdata/user_data/data/binance/ \
	-e 100

#! Start bot
cd ft_userdata/
freqtrade trade \
	--config user_data/configs/config.json \
	--strategy NostalgiaForInfinityX5

#! Web Server
freqtrade webserver \
	--verbose -v \
	--config user_data/configs/config.json \
	--datadir /home/hankniel/works/crypto/ft_userdata/user_data/data/binance/ \
	--logfile /home/hankniel/works/crypto/ft_userdata/user_data/logs/webserver.log

#! Update freqtrade
cd freqtrade/
./setup.sh --update

#! Install plotting library
conda activate freqtrade
pip install lightweight-charts
pip install pyqt5 pyqtwebengine
pip install pywebview
pip install pywebview[qt]
sudo apt install python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-webkit2-4.1 #? pywebview dependencies incase pywebview[qt] doesn't works.

#! nginx installation and mapping freqtrade
sudo ufw status
sudo ufw enable
sudo ufw allow 8989/tcp #? FreqUI port
sudo ufw allow 80/tcp #? HTTP port
sudo ufw allow 443/tcp #? HTTP port
sudo ufw status numbered
sudo ufw delete 4 #? or sudo ufw delete allow 8989/tcp

sudo apt update
sudo apt install nginx
sudo nano /etc/nginx/sites-available/trade.daoduydai.com
	# server {
	# 	listen 80;
	# 	server_name trade.daoduydai.com;

	# 	location / {
	# 		proxy_pass http://localhost:8989;
	# 		proxy_set_header Host $host;
	# 		proxy_set_header X-Real-IP $remote_addr;
	# 		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	# 		proxy_set_header X-Forwarded-Proto $scheme;
	# 	}

	# 	location /.well-known/acme-challenge/ {
	# 		root /var/www/html;
	# 		try_files $uri =404;
	# 	}
	# }
sudo nginx -t
sudo systemctl reload nginx

sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx
sudo ln -s /etc/nginx/sites-available/trade.daoduydai.com /etc/nginx/sites-enabled/
sudo certbot --nginx -d -v trade.daoduydai.com
sudo nginx -t
sudo systemctl restart nginx

nano /etc/nginx/nginx.conf
sudo systemctl stop nginx
sudo systemctl start nginx