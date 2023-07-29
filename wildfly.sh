#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install openjdk-11-jdk -y
sudo apt install apache2 -y

wget https://download.jboss.org/wildfly/24.0.1.Final/wildfly-24.0.1.Final.tar.gz
tar xf wildfly-24.0.1.Final.tar.gz
sudo mv wildfly-24.0.1.Final /opt/wildfly
sudo adduser --no-create-home --disabled-login --disabled-password --group wildfly
sudo useradd -g wildfly wildfly
sudo chown -R wildfly:wildfly /opt/wildfly

sudo bash -c 'cat > /etc/systemd/system/wildfly.service << EOF
[Unit]
Description=The WildFly Application Server
After=syslog.target network.target

[Service]
User=wildfly
Group=wildfly
ExecStart=/opt/wildfly/bin/standalone.sh -b=0.0.0.0
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'


sudo systemctl daemon-reload
sudo systemctl start wildfly
sudo systemctl enable wildfly

sudo mkdir /etc/apache2/ssl
sudo sed -i 's/<inet-address value="${jboss.bind.address.management:127.0.0.1}"/<inet-address value="${jboss.bind.address.management:0.0.0.0}"/g' /opt/wildfly/standalone/configuration/standalone.xml
sudo sed -i 's/<inet-address value="${jboss.bind.address:127.0.0.1}"/<inet-address value="${jboss.bind.address:0.0.0.0}"/g' /opt/wildfly/standalone/configuration/standalone.xml