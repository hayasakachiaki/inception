#!/bin/bash

set -e

read_secret() {
	var_name=$1
	file_var_name="${var_name}_FILE"
	file_path=$(eval "printf '%s' \"\${$file_var_name}\"")
	if [ -n "$file_path" ] && [ -f "$file_path" ]; then
		export "$var_name=$(cat "$file_path")"
	fi
}

read_secret db_pwd
read_secret WP_ADMIN_PWD
read_secret WP_PWD

mkdir -p /var/www/html
cd /var/www/html

if ! command -v wp >/dev/null 2>&1; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

if [ ! -f /var/www/html/wp-config.php ]; then
	wp core download --allow-root
	cp /wp-config.php /var/www/html/wp-config.php
fi

wp config set DB_NAME "$db_name" --allow-root
wp config set DB_USER "$db_user" --allow-root
wp config set DB_PASSWORD "$db_pwd" --allow-root


for i in $(seq 1 30); do
	if php -r '$db = @mysqli_connect("mariadb", getenv("db_user"), getenv("db_pwd"), getenv("db_name")); exit($db ? 0 : 1);'; then
		break
	fi
	if [ "$i" -eq 30 ]; then
		echo "Failed to connect to MariaDB" >&2
		exit 1
	fi
	sleep 2
done

if ! wp core is-installed --allow-root >/dev/null 2>&1; then
	wp core install --url="https://$DOMAIN_NAME/" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USR" --admin_password="$WP_ADMIN_PWD" --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root
	wp user create "$WP_USR" "$WP_EMAIL" --role=author --user_pass="$WP_PWD" --allow-root || true
	wp theme install astra --activate --allow-root || true
	wp plugin update --all --allow-root || true
fi

wp option update siteurl "https://$DOMAIN_NAME" --allow-root
wp option update home "https://$DOMAIN_NAME" --allow-root

PHP_FPM_CONF=$(find /etc/php -path '*/fpm/pool.d/www.conf' | head -n 1)
PHP_FPM_BIN=$(command -v php-fpm || find /usr/sbin -maxdepth 1 -name 'php-fpm*' | sort | tail -n 1)

sed -i 's|^listen = .*|listen = 0.0.0.0:9000|g' "$PHP_FPM_CONF"
sed -i 's|^;*listen.allowed_clients = .*|;listen.allowed_clients = 127.0.0.1|g' "$PHP_FPM_CONF"

chown -R www-data:www-data /var/www/html

mkdir -p /run/php

exec "$PHP_FPM_BIN" -F
