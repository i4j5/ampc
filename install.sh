#!/bin/bash

set -eo pipefail

has() {
  [[ -x "$(command -v "$1")" ]];
}

has_not() {
  ! has "$1" ;
}

ok() {
  echo -en "\033[37;1;42m → " $1 "OK \033[0m \n"
}

if has_not apache2; then
  sudo apt install -y apache2
  
  # Настройка виртуальных доменов
  curl -sS -O https://raw.githubusercontent.com/i4j5/ampc/master/000-default.conf
  sudo rm /etc/apache2/sites-available/000-default.conf
  sudo mv 000-default.conf /etc/apache2/sites-available
  ok "Настройка виртуальных доменов"
    
  # Включить rewrite
  sudo a2enmod rewrite
  ok "Включить Apache rewrite"
    
  # Перезапуск Apache2
  sudo service apache2 restart
  ok "Перезапуск Apache"
  
  sudo chown -R $USER:$USER /var/www
  ln -s /var/www ~/code
fi
ok "Apache"

if has_not mysql; then
  sudo apt install -y mysql-server
fi
ok "MySQL"

if has_not php; then
  sudo apt install -y php7.2-mysql \
       php7.2-curl \
       php7.2-json \
       php7.2-sqlite3 \
       php7.2-cgi \
       php7.2-zip \
       php7.2 \
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

echo -en "\n\033[37;1;40m Установка завершена! \033[0m \n\n"
