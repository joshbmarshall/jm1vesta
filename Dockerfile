FROM joshbmarshall/jm1hostbase

ENV DEBIAN_FRONTEND=noninteractive \
    VESTA=/usr/local/vesta \
    GOLANG_VERSION=1.10.1

RUN \
    cd /tmp \
    && echo "nginx mysql bind clamav ssl-cert dovecot dovenull Debian-exim debian-spamd" | xargs -n1 groupadd -K GID_MIN=100 -K GID_MAX=999 ${g} \
    && echo "nginx nginx mysql mysql bind bind clamav clamav dovecot dovecot dovenull dovenull Debian-exim Debian-exim debian-spamd debian-spamd" | xargs -n2 useradd -d /nonexistent -s /bin/false -K UID_MIN=100 -K UID_MAX=999 -g ${g} \
    && usermod -d /var/lib/mysql mysql \
    && usermod -d /var/cache/bind bind \
    && usermod -d /var/lib/clamav -a -G Debian-exim clamav && usermod -a -G mail clamav \
    && usermod -d /usr/lib/dovecot -a -G mail dovecot \
    && usermod -d /var/spool/exim4 -a -G mail Debian-exim \
    && usermod -d /var/lib/spamassassin -s /bin/sh -a -G mail debian-spamd \
    && curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && apt-get update && apt-get -y --no-install-recommends upgrade \
    && apt-get install -y --no-install-recommends libpcre3-dev libssl-dev dpkg-dev libgd-dev iproute uuid-dev \
    && apt-get install -yq php5.6-mbstring php5.6-cgi php5.6-cli php5.6-dev php5.6-common php5.6-xmlrpc php5.6-iconv php5.6-exif \
        php5.6-curl php5.6-enchant php5.6-imap php5.6-xsl php5.6-mysql php5.6-mysqlnd php5.6-pspell php5.6-gd php5.6-zip \
        php5.6-tidy php5.6-opcache php5.6-json php5.6-bz2 php5.6-mcrypt php5.6-readline php5.6-imagick php5.6-gmp php5.6-bcmath \
        php5.6-intl php5.6-sqlite3 php5.6-ldap php5.6-xml php5.6-dev php5.6-fpm php5.6-soap \
    && apt-get install -yq php7.0-mbstring php7.0-cgi php7.0-cli php7.0-dev php7.0-common php7.0-xmlrpc php7.0-iconv php7.0-exif \
        php7.0-curl php7.0-enchant php7.0-imap php7.0-xsl php7.0-mysql php7.0-mysqlnd php7.0-pspell php7.0-gd php7.0-zip \
        php7.0-tidy php7.0-opcache php7.0-json php7.0-bz2 php7.0-mcrypt php7.0-readline php7.0-imagick php7.0-gmp php7.0-bcmath \
        php7.0-intl php7.0-sqlite3 php7.0-ldap php7.0-xml php7.0-dev php7.0-fpm php7.0-sodium php7.0-soap \
    && apt-get install -yq php7.1-mbstring php7.1-cgi php7.1-cli php7.1-dev php7.1-common php7.1-xmlrpc php7.1-iconv php7.1-exif \
        php7.1-curl php7.1-enchant php7.1-imap php7.1-xsl php7.1-mysql php7.1-mysqlnd php7.1-pspell php7.1-gd php7.1-zip \
        php7.1-tidy php7.1-opcache php7.1-json php7.1-bz2 php7.1-mcrypt php7.1-readline php7.1-imagick php7.1-gmp php7.1-bcmath \
        php7.1-intl php7.1-sqlite3 php7.1-ldap php7.1-xml php7.1-dev php7.1-fpm php7.1-sodium php7.1-soap \
    && apt-get install -yq php7.2-mbstring php7.2-cgi php7.2-cli php7.2-dev php7.2-common php7.2-xmlrpc php7.2-iconv php7.2-exif \
        php7.2-curl php7.2-enchant php7.2-imap php7.2-xsl php7.2-mysql php7.2-mysqlnd php7.2-pspell php7.2-gd php7.2-zip \
        php7.2-tidy php7.2-opcache php7.2-json php7.2-bz2 php7.2-readline php7.2-imagick php7.2-gmp php7.2-bcmath \
        php7.2-intl php7.2-sqlite3 php7.2-ldap php7.2-xml php7.2-dev php7.2-fpm php7.2-soap \
    && rm -f /etc/apt/sources.list && mv /etc/apt/sources.list.bak /etc/apt/sources.list \
    && rm -rf /tmp/* \
    && apt-get -yf autoremove \
    && apt-get clean 

RUN \
    cd /tmp \
# begin setup for vesta
    && curl -SL https://vestacp.com/pub/vst-install-ubuntu.sh -o /tmp/vst-install-ubuntu.sh \
# fix mariadb instead of mysql
    && sed -i -e "s/mysql\-/mariadb\-/g" /tmp/vst-install-ubuntu.sh \
# begin install vesta
    && bash /tmp/vst-install-ubuntu.sh \
        --nginx yes --apache yes --phpfpm no \
        --vsftpd no --proftpd no \
        --named yes --exim yes --dovecot yes \
        --spamassassin yes --clamav no \
        --iptables yes --fail2ban yes \
        --mysql yes --postgresql no --remi yes \
	--softaculous no \
        --quota no --password b3ntHeat25 \
        -y no -f \
# begin apache stuff
    && service apache2 stop && service vesta stop \
# default fcgi and php to 7.2
    && mv /usr/bin/php-cgi /usr/bin/php-cgi-old \
    && ln -s /usr/bin/php-cgi7.2 /usr/bin/php-cgi \
    && update-alternatives --set php /usr/bin/php7.2 \
    && update-alternatives --set phar /usr/bin/phar7.2 \
    && update-alternatives --set phar.phar /usr/bin/phar.phar7.2 \
    && pecl config-set php_ini /etc/php/7.2/cli/php.ini \
    && pecl config-set ext_dir /usr/lib/php/20170718 \
    && pecl config-set php_bin /usr/bin/php7.2 \
    && pecl config-set php_suffix 7.2 \
# install additional mods since 7.2 became default in the php repo
    && apt-get install -yf --no-install-recommends libapache2-mod-php5.6 libapache2-mod-php7.0 libapache2-mod-php7.1 \
# fix v8js reference of json first
    && mv /etc/php/5.6/apache2/conf.d/20-json.ini /etc/php/5.6/apache2/conf.d/15-json.ini \
    && mv /etc/php/5.6/cli/conf.d/20-json.ini /etc/php/5.6/cli/conf.d/15-json.ini \
    && mv /etc/php/5.6/cgi/conf.d/20-json.ini /etc/php/5.6/cgi/conf.d/15-json.ini \
    && mv /etc/php/5.6/fpm/conf.d/20-json.ini /etc/php/5.6/fpm/conf.d/15-json.ini \
# install nodejs
    && apt-get install -yf --no-install-recommends nodejs \
# finish cleaning up
    && rm -rf /tmp/.spam* \
    && rm -rf /tmp/* \
    && apt-get -yf autoremove \
    && apt-get clean 

RUN apt-get install monit \
    && rm -rf /tmp/* \
    && apt-get -yf autoremove \
    && apt-get clean 

RUN wget -O /usr/bin/borg https://github.com/borgbackup/borg/releases/download/1.1.5/borg-linux64 \
 && chmod 755 /usr/bin/borg

RUN ln -fs /usr/share/zoneinfo/Australia/Brisbane /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata

COPY rootfs/. /

RUN \
    cd /tmp \
# tweaks
    && chmod +x /etc/init.d/dovecot \
    && chmod +x /etc/service/sshd/run \
    && chmod +x /etc/my_init.d/startup.sh \
    && mv /sysprepz/admin/bin/vesta-*.sh /bin \
# php 7.0
    && echo "extension=v8js.so" > /etc/php/7.0/mods-available/v8js.ini \
    && ln -sf /etc/php/7.0/mods-available/v8js.ini /etc/php/7.0/apache2/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.0/mods-available/v8js.ini /etc/php/7.0/cli/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.0/mods-available/v8js.ini /etc/php/7.0/cgi/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.0/mods-available/v8js.ini /etc/php/7.0/fpm/conf.d/20-v8js.ini \
# php 7.1
    && echo "extension=v8js.so" > /etc/php/7.1/mods-available/v8js.ini \
    && ln -sf /etc/php/7.1/mods-available/v8js.ini /etc/php/7.1/apache2/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.1/mods-available/v8js.ini /etc/php/7.1/cli/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.1/mods-available/v8js.ini /etc/php/7.1/cgi/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.1/mods-available/v8js.ini /etc/php/7.1/fpm/conf.d/20-v8js.ini \
# php 7.2
    && echo "extension=v8js.so" > /etc/php/7.2/mods-available/v8js.ini \
    && ln -sf /etc/php/7.2/mods-available/v8js.ini /etc/php/7.2/apache2/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.2/mods-available/v8js.ini /etc/php/7.2/cli/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.2/mods-available/v8js.ini /etc/php/7.2/cgi/conf.d/20-v8js.ini \
    && ln -sf /etc/php/7.2/mods-available/v8js.ini /etc/php/7.2/fpm/conf.d/20-v8js.ini \
# performance tweaks
    && chmod 0755 /etc/init.d/disable-transparent-hugepages \
# secure ssh
    && sed -i -e "s/PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config \
    && sed -i -e "s/^#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config \
# initialize ips for docker support
    && cd /usr/local/vesta/data/ips && mv * 127.0.0.1 \
    && cd /etc/apache2/conf.d \
    && sed -i -e "s/172.*.*.*:80/127.0.0.1:80/g" * \
    && sed -i -e "s/172.*.*.*:8443/127.0.0.1:8443/g" * \
    && cd /etc/nginx/conf.d \
    && sed -i -e "s/172.*.*.*:80/127.0.0.1:80/g" * \
    && sed -i -e "s/172.*.*.*:8080/127.0.0.1:8080/g" * \
    && mv 172.*.*.*.conf 127.0.0.1.conf \
    && cd /home/admin/conf/web \
    && sed -i -e "s/172.*.*.*:80;/80;/g" * \
    && sed -i -e "s/172.*.*.*:8080/127.0.0.1:8080/g" * \
    && cd /tmp \
# php stuff - after vesta because of vesta-php installs
    && sed -i "s/.*always_populate_raw_post_data.*/always_populate_raw_post_data = -1/" /etc/php/5.6/apache2/php.ini \
    && sed -i "s/.*always_populate_raw_post_data.*/always_populate_raw_post_data = -1/" /etc/php/5.6/cli/php.ini \
    && sed -i "s/.*always_populate_raw_post_data.*/always_populate_raw_post_data = -1/" /etc/php/5.6/cgi/php.ini \
    && sed -i "s/.*always_populate_raw_post_data.*/always_populate_raw_post_data = -1/" /etc/php/5.6/fpm/php.ini \
# upload max file size
# php 7.0
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.0/apache2/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.0/cli/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.0/cgi/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.0/fpm/php.ini \
# php 5.6
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/5.6/apache2/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/5.6/cli/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/5.6/cgi/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/5.6/fpm/php.ini \
# php 7.1
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.1/apache2/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.1/cli/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.1/cgi/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.1/fpm/php.ini \
#php 7.2
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.2/apache2/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.2/cli/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.2/cgi/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 600M/" /etc/php/7.2/fpm/php.ini \
# post max size
# php 7.0
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.0/apache2/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.0/cli/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.0/cgi/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.0/fpm/php.ini \
# php 5.6
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/5.6/apache2/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/5.6/cli/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/5.6/cgi/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/5.6/fpm/php.ini \
# php 7.1
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.1/apache2/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.1/cli/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.1/cgi/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.1/fpm/php.ini \
# php 7.2
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.2/apache2/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.2/cli/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.2/cgi/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 600M/" /etc/php/7.2/fpm/php.ini \
# output buffering
# php 7.0
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.0/apache2/php.ini \                                                                                                     
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.0/cli/php.ini \          
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.0/cgi/php.ini \    
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.0/fpm/php.ini \              
# php 5.6
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/5.6/apache2/php.ini \      
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/5.6/cli/php.ini \          
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/5.6/cgi/php.ini \     
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/5.6/fpm/php.ini \              
# php 7.1
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.1/apache2/php.ini \                   
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.1/cli/php.ini \          
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.1/cgi/php.ini \                        
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.1/fpm/php.ini \                                           
# php 7.2
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.2/apache2/php.ini \             
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.2/cli/php.ini \          
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.2/cgi/php.ini \                                           
    && sed -i "s/output_buffering = 4096/output_buffering = Off/" /etc/php/7.2/fpm/php.ini \
# max input time
# php 7.0
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.0/apache2/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.0/cli/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.0/cgi/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.0/fpm/php.ini \
# php 5.6
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/5.6/apache2/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/5.6/cli/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/5.6/cgi/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/5.6/fpm/php.ini \
# php 7.1
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.1/apache2/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.1/cli/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.1/cgi/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.1/fpm/php.ini \
# php 7.2
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.2/apache2/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.2/cli/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.2/cgi/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 3600/" /etc/php/7.2/fpm/php.ini \
# max execution time
# php 7.0
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.0/apache2/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.0/cli/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.0/cgi/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.0/fpm/php.ini \
# php 5.6
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/5.6/apache2/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/5.6/cli/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/5.6/cgi/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/5.6/fpm/php.ini \
# php 7.1
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.1/apache2/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.1/cli/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.1/cgi/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.1/fpm/php.ini \
# php 7.2
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.2/apache2/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.2/cli/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.2/cgi/php.ini \
    && sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.2/fpm/php.ini \
# exim path
# php 7.0
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.0/apache2/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.0/cli/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.0/cgi/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.0/fpm/php.ini \
# php 5.6
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/5.6/apache2/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/5.6/cli/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/5.6/cgi/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/5.6/fpm/php.ini \
# php 7.1
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.1/apache2/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.1/cli/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.1/cgi/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.1/fpm/php.ini \
# php 7.2
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.2/apache2/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.2/cli/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.2/cgi/php.ini \
    && sed -i -e "s/;sendmail_path =/sendmail_path = \/usr\/sbin\/exim \-t/g" /etc/php/7.2/fpm/php.ini \
# set same upload limit for php fcgi
    && sed -i "s/FcgidConnectTimeout 20/FcgidMaxRequestLen 629145600\n  FcgidConnectTimeout 20/" /etc/apache2/mods-available/fcgid.conf \
# add multiple php fcgi and custom templates
    && rsync -a /sysprepz/apache2-templates/* /usr/local/vesta/data/templates/web/apache2/ \
    && rsync -a /sysprepz/nginx-templates/* /usr/local/vesta/data/templates/web/nginx/ \
# fix docker nginx ips
    && sed -i -e "s/\%ip\%\:\%proxy\_port\%\;/\%proxy\_port\%\;/g" /usr/local/vesta/data/templates/web/nginx/*.tpl \
    && sed -i -e "s/\%ip\%\:\%proxy\_ssl\_port\%\;/\%proxy\_ssl\_port\%\;/g" /usr/local/vesta/data/templates/web/nginx/*.stpl \
    && sed -i -e "s/\%ip\%\:\%proxy\_port\%\;/\%proxy\_port\%\;/g" /usr/local/vesta/data/templates/web/nginx/php-fpm/*.tpl \
    && sed -i -e "s/\%ip\%\:\%proxy\_ssl\_port\%\;/\%proxy\_ssl\_port\%\;/g" /usr/local/vesta/data/templates/web/nginx/php-fpm/*.stpl \
    && sed -i -e "s/ include \%home\%\/\%user\%\/conf\/web\/nginx\.\%domain\%/ include \%home\%\/\%user\%\/web\/\%domain\%\/private\/*.conf;\n    include \%home\%\/\%user\%\/conf\/web\/nginx\.\%domain\%/g" /usr/local/vesta/data/templates/web/nginx/*.tpl \
    && sed -i -e "s/ include \%home\%\/\%user\%\/conf\/web\/nginx\.\%domain\%/ include \%home\%\/\%user\%\/web\/\%domain\%\/private\/*.conf;\n    include \%home\%\/\%user\%\/conf\/web\/nginx\.\%domain\%/g" /usr/local/vesta/data/templates/web/nginx/*.stpl \
    && bash /usr/local/vesta/upd/switch_rpath.sh \
# docker specific patching
    && sed -i -e "s/^if (\$dir_name/\/\/if (\$dir_name/g" /usr/local/vesta/web/list/rrd/image.php \
# increase open file limit for nginx and apache
    && echo "\n\n* soft nofile 800000\n* hard nofile 800000\n\n" >> /etc/security/limits.conf \
# apache stuff
    && echo "\nServerName localhost\n" >> /etc/apache2/apache2.conf \
    && a2enmod headers \
# download new auto host ssl
    && curl -SL https://raw.githubusercontent.com/serghey-rodin/vesta/master/bin/v-update-host-certificate --output /usr/local/vesta/bin/v-update-host-certificate \
    && chmod +x /usr/local/vesta/bin/v-update-host-certificate \
# disable localhost redirect to bad default IP
    && sed -i -e "s/^NAT=.*/NAT=\'\'/g" /usr/local/vesta/data/ips/* \
    && service mysql stop && systemctl disable mysql \
    && service fail2ban stop && systemctl disable fail2ban \
    && service nginx stop && systemctl disable nginx \
    && service apache2 stop && systemctl disable apache2 \
    && sed -i -e "s/\/var\/lib\/mysql/\/vesta\/var\/lib\/mysql/g" /etc/mysql/my.cnf \
# for letsencrypt
    && touch /usr/local/vesta/data/queue/letsencrypt.pipe \
# disable php*admin and roundcube by default, backup the config first - see README.md    
    && mkdir -p /etc/apache2/conf-d \
    && rsync -a /etc/apache2/conf.d/* /etc/apache2/conf-d \
    && rm -f /etc/apache2/conf.d/php*.conf \
    && rm -f /etc/apache2/conf.d/roundcube.conf \
# begin folder redirections
    && mkdir -p /vesta-start/etc \
    && mkdir -p /vesta-start/var/lib \
    && mkdir -p /vesta-start/local \
# apache
    && mv /etc/apache2 /vesta-start/etc/apache2 \
    && rm -rf /etc/apache2 \
    && ln -s /vesta/etc/apache2 /etc/apache2 \
# ssh
    && mv /etc/ssh /vesta-start/etc/ssh \
    && rm -rf /etc/ssh \
    && ln -s /vesta/etc/ssh /etc/ssh \
# fail2ban
    && mv /etc/fail2ban /vesta-start/etc/fail2ban \
    && rm -rf /etc/fail2ban \
    && ln -s /vesta/etc/fail2ban /etc/fail2ban \
# php
    && mv /etc/php /vesta-start/etc/php \
    && rm -rf /etc/php \
    && ln -s /vesta/etc/php /etc/php \
# nginx
    && mv /etc/nginx   /vesta-start/etc/nginx \
    && rm -rf /etc/nginx \
    && ln -s /vesta/etc/nginx /etc/nginx \
# exim
    && mv /etc/exim4   /vesta-start/etc/exim4 \
    && rm -rf /etc/exim4 \
    && ln -s /vesta/etc/exim4 /etc/exim4 \
# spamassassin
    && mv /etc/spamassassin   /vesta-start/etc/spamassassin \
    && rm -rf /etc/spamassassin \
    && ln -s /vesta/etc/spamassassin /etc/spamassassin \
# mail conf
    && mv /etc/mail   /vesta-start/etc/mail \
    && rm -rf /etc/mail \
    && ln -s /vesta/etc/mail /etc/mail \
# awstats
    && mv /etc/awstats /vesta-start/etc/awstats \
    && rm -rf /etc/awstats \
    && ln -s /vesta/etc/awstats /etc/awstats \
# dovecot
    && mv /etc/dovecot /vesta-start/etc/dovecot \
    && rm -rf /etc/dovecot \
    && ln -s /vesta/etc/dovecot /etc/dovecot \
# mysql config
    && mv /etc/mysql   /vesta-start/etc/mysql \
    && rm -rf /etc/mysql \
    && ln -s /vesta/etc/mysql /etc/mysql \
# mysql
    && mv /var/lib/mysql /vesta-start/var/lib/mysql \
    && rm -rf /var/lib/mysql \
    && ln -s /vesta/var/lib/mysql /var/lib/mysql \
# root    
    && mv /root /vesta-start/root \
    && rm -rf /root \
    && ln -s /vesta/root /root \
# vesta
    && mv /usr/local/vesta /vesta-start/local/vesta \
    && rm -rf /usr/local/vesta \
    && ln -s /vesta/local/vesta /usr/local/vesta \
# timezone
#    && mv /etc/timezone /vesta-start/etc/timezone \
#    && rm -rf /etc/timezone \
#    && ln -s /vesta/etc/timezone /etc/timezone \
# bind
    && mv /etc/bind /vesta-start/etc/bind \
    && rm -rf /etc/bind \
    && ln -s /vesta/etc/bind /etc/bind \
#profile
    && mv /etc/profile /vesta-start/etc/profile \
    && rm -rf /etc/profile \
    && ln -s /vesta/etc/profile /etc/profile \
# logs
    && mv /var/log /vesta-start/var/log \
    && rm -rf /var/log \
    && ln -s /vesta/var/log /var/log \
# home
    && mkdir -p /sysprepz/home \
    && rsync -a /home/* /sysprepz/home \
    && mv /sysprepz/admin/bin /sysprepz/home/admin \
    && chown -R admin:admin /sysprepz/home/admin/bin \
# sessions
    && mkdir -p /vesta-start/local/vesta/data/sessions \
    && chmod 775 /vesta-start/local/vesta/data/sessions \
    && chown root:admin /vesta-start/local/vesta/data/sessions \
# fix roundcube error log permission
    && touch /vesta-start/var/log/roundcube/errors \
    && chown -R www-data:www-data /vesta-start/var/log/roundcube \
    && chmod 775 /vesta-start/var/log/roundcube/errors \
# finish cleaning up
    && rm -rf /backup/.etc \
    && rm -rf /tmp/* \
    && apt-get -yf autoremove \
    && apt-get clean 


VOLUME ["/vesta", "/home", "/backup"]

EXPOSE 22 25 53 54 80 110 143 443 465 587 993 995 1194 3000 3306 5432 5984 6379 8083 10022 11211 27017
