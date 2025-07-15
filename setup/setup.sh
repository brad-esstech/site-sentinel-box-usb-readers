#!/bin/bash

echo "Checking Ubuntu version..."
lsb_release=$(lsb_release -rs)

if [[ ${lsb_release} != "22.04" ]]; then
  echo "ERROR: This script is designed for Ubuntu 22.04 Jammy Jellyfish. You're running ${lsb_release}."
  exit
fi
echo "version is OK (${lsb_release}). Continuing."

echo "Upgrading all the things..."
sudo apt-get -y update && sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

echo "Installing required libraries..."
sudo apt-get install -y ruby-bundler build-essential ruby-dev libevdev-dev libevdev-tools libudev0 python3-pip python3-rpi.gpio redis-server monit

echo "Setting timezone..."
sudo timedatectl set-timezone Australia/Perth

echo "Installing Ruby libraries..."
cd ~/site-sentinel-box-usb-readers
bundle install

echo "Copying config files..."
cp config.rb.example config.rb
cp config.py.example config.py

echo "Setting up cron job for access list download..."
sudo systemctl enable cron
line="*/1 * * * * /usr/bin/ruby /home/ubuntu/site-sentinel-box-usb-readers/get_access_list.rb"
(crontab -u ubuntu -l; echo "$line" ) | crontab -u ubuntu -

echo "Allow Python to access GPIO ports..."
sudo chmod og+rwx /dev/gpio*

# Allow access to input devices (probably not needed now?)
# sudo usermod -a -G input ubuntu

echo "Allow access to readers..."
sudo cp ~/site-sentinel-box-usb-readers/setup/rfideas.rules /etc/udev/rules.d/rfideas.rules
sudo udevadm trigger

echo "Setting up services..."
sudo cp ~/site-sentinel-box-usb-readers/setup/reader_ingress.service /etc/systemd/system/reader_ingress.service
sudo cp ~/site-sentinel-box-usb-readers/setup/reader_egress.service /etc/systemd/system/reader_egress.service
sudo cp ~/site-sentinel-box-usb-readers/setup/reader_ingress2.service /etc/systemd/system/reader_ingress2.service
sudo cp ~/site-sentinel-box-usb-readers/setup/reader_egress2.service /etc/systemd/system/reader_egress2.service
sudo cp ~/site-sentinel-box-usb-readers/setup/sidekiq.service /etc/systemd/system/sidekiq.service

echo "Load, enable and start services..."
sudo systemctl daemon-reload
sudo systemctl enable reader_ingress.service
sudo systemctl enable reader_egress.service
sudo systemctl enable reader_ingress2.service
sudo systemctl enable reader_egress2.service
sudo systemctl enable sidekiq.service

echo "Setting up monit..."
sudo cp ~/site-sentinel-box-usb-readers/setup/monitrc /etc/monit/monitrc
sudo chmod 0700 /etc/monit/monitrc
sudo service monit restart

echo "Setting up Papertrail..."
cd ~/
wget -qO - --header="X-Papertrail-Token: 38vRUorKt0nhgjbmiaRJ" https://papertrailapp.com/destinations/37385845/setup.sh | sudo bash
wget https://github.com/papertrail/remote_syslog2/releases/download/v0.20/remote_syslog_linux_armhf.tar.gz
tar xzf ./remote_syslog*.tar.gz
cd remote_syslog
sudo cp ./remote_syslog /usr/local/bin
sleep 1
cd ~/
rm remote_syslog_linux_armhf.tar*
rm -rf remote_syslog
sudo cp ~/site-sentinel-box-usb-readers/setup/log_files.yml /etc/log_files.yml
sudo cp ~/site-sentinel-box-usb-readers/setup/remote_syslog.service /etc/systemd/system/remote_syslog.service
sudo systemctl enable remote_syslog.service
sudo systemctl start remote_syslog.service
