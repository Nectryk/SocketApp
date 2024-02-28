#!/bin/bash

sudo apt update
sudo apt install apache2 php-mysql php8.1 libapache2-mod-php composer mysql-client php8.1-xml -y

export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"

cd /var/www/html/ 
sudo chown ubuntu ../html/
sudo rm index.html
sudo git clone https://github.com/Nectryk/SocketApp.git
sudo cp -r SocketApp/TCP_IP_PHP/* SocketApp/clientRegister.sql .
composer install

sudo systemctl restart apache2