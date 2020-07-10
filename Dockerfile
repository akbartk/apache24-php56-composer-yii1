# Base Image
FROM debian:stretch-slim

MAINTAINER akbarTK <akbartk@gmail.com>

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV DEFAULT_ROOT=/var/www/html
ENV DEBIAN_FRONTEND noninteractive
ENV ROOT_PASSWORD=root
ENV LOCALE en_US.UTF-8
ENV TZ=Asia/Jakarta
ENV PHP_V=5.6
#ENV PHP_V=5.6/7.2

# Set repositories
RUN \
    echo "deb http://ftp.de.debian.org/debian/ stretch main non-free contrib" > /etc/apt/sources.list && \
    echo "deb-src http://ftp.de.debian.org/debian/ stretch main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && apt-get -yqq upgrade;

# Install komponen 
RUN apt-get -yqq install \
    apt-utils \
    build-essential \
    debconf-utils \
    debconf \
    mysql-client \
    locales \
    curl \
    wget \
    unzip \
    patch \
    rsync \
    vim \
    nano \
    openssh-client \
    git \
    bash-completion \
    locales \
    libjpeg-turbo-progs libjpeg-progs \
    supervisor \
    pngcrush optipng;

# Install locale
RUN \
  sed -i -e "s/# $LOCALE/$LOCALE/" /etc/locale.gen && \
  echo "LANG=$LOCALE">/etc/default/locale && \
  dpkg-reconfigure --frontend noninteractive locales && \
  update-locale LANG=$LOCALE;

RUN wget -qO- https://github.com/wodby/gotpl/releases/download/0.1.5/gotpl-linux-amd64-0.1.5.tar.gz | tar xz -C /usr/local/bin;

# Install Repo PHP 
RUN \
    apt-get update && \
    apt-get install -yqq --no-install-recommends apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get autoremove && apt-get clean \
    && rm -rf /tmp/* /root/.cache /var/lib/apt/lists/*;

# Install Apache
RUN apt-get update && \
    apt-get --no-install-recommends install -yqq  \
    apache2 \
    apache2-utils \
    curl \
    ssmtp \
    php${PHP_V} 		\
    php${PHP_V}-bcmath   \
    php${PHP_V}-bz2   \
    php${PHP_V}-curl \
    php${PHP_V}-dev 		\
    php${PHP_V}-gd 		\
    php${PHP_V}-dom		\
    php${PHP_V}-imap     \
    php${PHP_V}-imagick  \
    php${PHP_V}-intl 		\
    php${PHP_V}-json 		\
    php${PHP_V}-ldap 		\
    php${PHP_V}-mbstring	\
    php${PHP_V}-mysql		\
    php${PHP_V}-oauth		\
    php${PHP_V}-odbc		\
    php${PHP_V}-uploadprogress \
    php${PHP_V}-ssh2		\
    php${PHP_V}-xml		\
    php${PHP_V}-zip		\
    php${PHP_V}-solr		\
    php${PHP_V}-apcu		\
    php${PHP_V}-opcache	\
    php${PHP_V}-memcache 	\
    php${PHP_V}-memcached 	\
    php${PHP_V}-redis		\
    php${PHP_V}-xdebug		\
    libapache2-mod-php${PHP_V} \
    && a2enmod actions proxy proxy_fcgi expires proxy_http authn_core alias headers authz_core authz_host authz_user dir env mime reqtimeout rewrite deflate ssl \
    && apt-get autoremove && apt-get clean \
    && rm -rf /tmp/* /root/.cache /var/lib/apt/lists/*;

RUN echo Asia/Jakarta > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# autorise .htaccess files
RUN \
  sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf;

# Install APC Manual
RUN \
  echo "extension=apcu.so" > /etc/php/${PHP_V}/mods-available/apcu_bc.ini && \
  echo "extension=apc.so" >> /etc/php/${PHP_V}/mods-available/apcu_bc.ini;

# Install composer
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN mkdir /var/composer
RUN composer require yiisoft/yii --working-dir=/var/composer
RUN chown -R www-data:www-data /var/composer

#ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
#ADD start.sh /bootstrap/start.sh
COPY info.php /var/www/html/
COPY etc/ssh/sshd_config /etc/ssh/sshd_config

RUN rm -rf /var/www/html/index.html && chown -R www-data:www-data /var/www/html && \
    mv /etc/apache2/sites-available /var/www/vhost && \
    ln -s /var/www/vhost/ /etc/apache2/sites-available && \
    chown -R root:root /var/www/vhost;

# ssh
RUN apt-get update \
    && apt-get --no-install-recommends install -y openssh-server bash \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && mkdir -p /root/.ssh;

RUN mkdir -p /var/run/sshd \
    && echo root:${ROOT_PASSWORD} | chpasswd \
    && echo "Start Success !" \
    && date -R;
    
EXPOSE 2323 80 443

# clean apt cache
RUN apt-get autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /root/.cache /var/lib/apt/lists/*;

# setsebool
CMD setsebool -P httpd_can_network_connect 1
CMD setsebool -P httpd_can_network_connect_db 1

# Workdir
WORKDIR /var/www/

ADD supervisord.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord"]
