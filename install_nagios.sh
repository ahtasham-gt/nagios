#!/bin/bash

# Update system
sudo apt update

# Install dependencies
sudo apt install -y apache2 php libapache2-mod-php git build-essential libgd-dev unzip wget

# Download Nagios source
wget https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.5.6/nagios-4.5.6.tar.gz
tar -zxvf nagios-4.5.6.tar.gz
cd nagios-4.5.6

# Configure and build Nagios
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all

# Create user and group
sudo make install-groups-users
sudo usermod -aG nagios www-data

# Install Nagios binaries and configs
sudo make install
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

# Create Nagios systemd service file (if not already present)
if [ ! -f /etc/systemd/system/nagios.service ]; then
  cat <<EOF | sudo tee /etc/systemd/system/nagios.service
[Unit]
Description=Nagios Core Monitoring Service
After=network.target apache2.service

[Service]
Type=forking
ExecStart=/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg
ExecStop=/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
User=nagios
Group=nagios
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
fi

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start services
sudo systemctl enable apache2
sudo systemctl enable nagios
sudo systemctl restart apache2
sudo systemctl start nagios

# Create Nagios admin user for web UI
sudo htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin admin123

echo "✅ Nagios installation complete."
echo "🌐 Access it via: http://$(curl -s ifconfig.me)/nagios"

