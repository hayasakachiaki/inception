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

read_secret db1_pwd
read_secret db_root_pwd

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

service mariadb start || service mysql start

echo "CREATE DATABASE IF NOT EXISTS $db1_name ;" > db1.sql
echo "CREATE USER IF NOT EXISTS '$db1_user'@'%' IDENTIFIED BY '$db1_pwd' ;" >> db1.sql
echo "GRANT ALL PRIVILEGES ON $db1_name.* TO '$db1_user'@'%' ;" >> db1.sql
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$db_root_pwd' ;" >> db1.sql
echo "FLUSH PRIVILEGES;" >> db1.sql

if mysql -uroot -p"$db_root_pwd" -e "SELECT 1;" >/dev/null 2>&1; then
	mysql -uroot -p"$db_root_pwd" < db1.sql
else
	mysql < db1.sql
fi

kill $(cat /var/run/mysqld/mysqld.pid)

exec mysqld
