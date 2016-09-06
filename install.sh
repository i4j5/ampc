#!/bin/bash

set -eo pipefail

has() {
  [[ -x "$(command -v "$1")" ]];
}

has_not() {
  ! has "$1" ;
}

ok() {
  echo "→ "$1" OK"
}

if has_not apache2; then
  sudo apt install -y apache2
  
  # Setup vhosts
  curl -sS -O https://gist.githubusercontent.com/claudiosmweb/ab41b5e8693eea7c02b8/raw/392305085efa1347c26498a1a5027037ae9c73be/000-default.conf
  sudo rm /etc/apache2/sites-available/000-default.conf
  sudo mv 000-default.conf /etc/apache2/sites-available
  ok "Setup vhosts"
    
  # Enable rewrite
  sudo a2enmod rewrite
  ok "Enable Apache rewrite"
    
  # Restart Apache2
  sudo service apache2 restart
  ok "Restart Apache"
  
  sudo chown -R $USER:$USER /var/www
  ln -s /var/www ~/code
fi
ok "Apache"

if has_not mysql; then
  sudo apt install -y mysql-server
fi
ok "MySQL"

if has_not php; then
  sudo apt install -y php7.0-mysql \
       php7.0-curl \
       php7.0-json \
       php7.0-cgi \
       php7.0 \
       libapache2-mod-php7.0
fi
ok "PHP"

if ! [[ -d "/etc/phpmyadmin" ]]; then
  sudo apt install -y phpmyadmin
  sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-enabled/phpmyadmin.conf
fi
ok "PHPMyAdmin"

if has_not composer; then
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
fi
ok "Composer"

ok "Installation finished!"