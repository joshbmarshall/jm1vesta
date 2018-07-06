#!/bin/bash

export TERM=xterm

if [ ! -f /home/admin/bin/my-startup.sh ]; then
    echo "[i] running for the 1st time"
    rsync --update -raz /vesta-start/* /vesta
    rsync --update -raz /sysprepz/home/* /home
# work around for AUFS bug
# as per https://github.com/docker/docker/issues/783#issuecomment-56013588
    mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private
# save some bytes, you can do it later
#    rm -rf /sysprepz
#    rm -rf /vesta-start
fi

# restore current users
if [ -f /backup/.etc/passwd ]; then
    echo "[i] restoring existing users"
	# restore users
	rsync -a /backup/.etc/passwd /etc/passwd
	rsync -a /backup/.etc/shadow /etc/shadow
	rsync -a /backup/.etc/gshadow /etc/gshadow
	rsync -a /backup/.etc/group /etc/group
fi

# make sure runit services are running across restart
find /etc/service/ -name "down" -exec rm -rf {} \;

if [ -f /etc/nginx/nginx.new ]; then
    echo "[i] init nginx"
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.old
	mv /etc/nginx/nginx.new /etc/nginx/nginx.conf
fi

if [ -f /etc/fail2ban/jail.new ]; then
    echo "[i] init fail2ban"
    mv /etc/fail2ban/jail.local /etc/fail2ban/jail-local.bak
    mv /etc/fail2ban/jail.new /etc/fail2ban/jail.local
fi

# force some config files
cp /sysprepz/bind/named.conf.options /etc/bind/named.conf.options
cp /sysprepz/exim/exim4.conf.template /etc/exim4/exim4.conf.template
chown root /etc/exim4/exim4.conf.template
rsync --delete --update -raz /sysprepz/packages/ /usr/local/vesta/data/packages/

# load root ssh keys
rsync --update -raz /sysprepz/rootssh/ /root/.ssh/
chmod 400 /root/.ssh/id_rbackup
chmod 700 /root/.ssh

# starting Vesta
if [ -f /home/admin/bin/my-startup.sh ]; then
    echo "[i] running /home/admin/bin/my-startup.sh"
    bash /home/admin/bin/my-startup.sh
else
    echo "[err] unable to locate /home/admin/bin/my-startup.sh"
fi

# Start PHP-FPM
/etc/init.d/php5.6-fpm restart
/etc/init.d/php7.0-fpm restart
/etc/init.d/php7.1-fpm restart
/etc/init.d/php7.2-fpm restart

# start monit
/etc/init.d/monit restart

# auto ssl on start
if [ -f /bin/vesta-auto-ssl.sh ]; then
	echo "[i] running /bin/vesta-auto-ssl.sh"
	bash /bin/vesta-auto-ssl.sh
fi
