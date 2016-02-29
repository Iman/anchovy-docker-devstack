FROM ubuntu:14.04
MAINTAINER Iman Samizadeh

ENV PHP_VERSION 5-5.6
ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_GB.UTF-8
ENV LC_ALL en_GB.UTF-8
ENV LANGUAGE en_GB:en
ENV DEV 0

# Configure Timezone
COPY config/timezone /etc/timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Installl packages and libs
RUN set -x \
&& apt-get update -q \
&& apt-get install -yqq locales \
&& dpkg-reconfigure locales \
&& locale-gen en_GB.UTF-8 \
&& apt-get install -yqq apt-utils wget curl software-properties-common python-software-properties \
&& add-apt-repository -y ppa:ondrej/php$PHP_VERSION \
&& add-apt-repository ppa:nginx/stable \
&& echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list \
&& wget -qO - https://packagecloud.io/gpg.key | apt-key add - \
&& apt-get update -q \
&& apt-get upgrade -yqq \
&& apt-get install -yqq gettext-base nginx php5 php5-xdebug php5-fpm php5-cli php5-intl php5-mcrypt php5-mysql php5-mongo php5-memcache php5-memcached php5-xmlrpc php5-curl php-pear php5-dev phpunit npm git gcc build-essential zlib1g-dev preload libpcre3 libpcre3-dev unzip dpkg-dev blackfire-php blackfire-agent supervisor\
&& apt-get remove --purge -y software-properties-common \
&& apt-get update -q \
&& apt-get autoremove -y \
&& apt-get clean \
&& apt-get autoclean \
&& echo -n > /var/lib/apt/extended_states \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /usr/share/man/?? \
&& rm -rf /usr/share/man/??_*

# Install global node packages
RUN npm install -g uglifycss uglify-js less coffee-script socket.io purify-css bower

# Configure php
COPY config/www.conf /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
sed -i -e "s/date.timezone =.*/date.timezone = UTC/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/;realpath_cache_size = 16k/realpath_cache_size = 4096k/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/;realpath_cache_ttl = 120/realpath_cache_ttl = 7200/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/max_execution_time = 30/max_execution_time = 600/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/memory_limit = 128M/memory_limit = 1024M/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/;?opcache.enable=.*/opcache.enable=1/g" /etc/php5/fpm/php.ini && \
sed -i -e "s/date.timezone =.*/date.timezone = UTC/g" /etc/php5/cli/php.ini && \
sed -i -e "s/;realpath_cache_size = 16k/realpath_cache_size = 4096k/g" /etc/php5/cli/php.ini && \
sed -i -e "s/;realpath_cache_ttl = 120/realpath_cache_ttl = 7200/g" /etc/php5/cli/php.ini && \
sed -i -e "s/max_execution_time = 30/max_execution_time = 600/g" /etc/php5/cli/php.ini && \
sed -i -e "s/memory_limit = 128M/memory_limit = 1024M/g" /etc/php5/cli/php.ini && \
sed -i -e "s/;?opcache.enable=.*/opcache.enable=1/g" /etc/php5/cli/php.ini

# Install and enablepecl extensions
RUN pecl install radius mongo memcached memcache
COPY config/extensions/radius.ini /etc/php5/mods-available/radius.ini
COPY config/extensions/mongo.ini /etc/php5/mods-available/mongo.ini
COPY config/extensions/memcache.ini /etc/php5/mods-available/memcache.ini
COPY config/extensions/memcached.ini /etc/php5/mods-available/memcached.ini
RUN php5enmod radius \
&& php5enmod mongo \
&& php5enmod memcached \
&& php5enmod memcache

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV VAULT_ADDR "http://vault:8200"

# Add configuration and keys for nginx
RUN mkdir -p /etc/nginx/ssl
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/anchovy.conf /etc/nginx/conf.d/anchovy.tmpl

# Copy scripts
RUN apt-get update && apt-get install -yqq jq
RUN mkdir -p /opt/anchovy/bin/
COPY scripts/*.sh /opt/anchovy/bin/
RUN chmod u+x /opt/anchovy/bin/*.sh

# Copy supervisor configuration
COPY config/supervisord.conf /etc/supervisord.conf

EXPOSE 80 443

ENTRYPOINT /opt/anchovy/bin/entrypoint.sh
