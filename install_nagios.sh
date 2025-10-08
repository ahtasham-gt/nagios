#!/bin/bash
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php git build-essential libgd-dev unzip wget
wget https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.5.6/nagios-4.5.6.tar.gz
tar -zxvf nagios-4.5.6.tar.gz
cd nagios-4.5.6
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all
sudo make install-groups-users
sudo usermod -aG nagios www-data
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf
sudo htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin admin123
sudo systemctl restart apache2
sudo systemctl start nagios
echo "Nagios installation complete. Access it via http://$(curl -s ifconfig.me)/nagios"
