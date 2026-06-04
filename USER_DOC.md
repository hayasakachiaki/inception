# User Documentation

## Services

This stack provides a WordPress website served through NGINX over HTTPS. MariaDB stores the WordPress database. WordPress and MariaDB are not directly exposed to the host; only NGINX publishes port 443.

## Start and stop

Start the project from the repository root:

```sh
make
```

Stop the running containers without deleting them:

```sh
make stop
```

Start stopped containers again:

```sh
make start
```

Remove containers and the Docker network:

```sh
make down
```

## Access

Open the website at:

```text
https://mawako.42.fr
```

Open the administration panel at:

```text
https://mawako.42.fr/wp-admin
```

The certificate is self-signed, so a browser warning is expected.

## Credentials

Local credentials are stored in ignored files under `secrets/`. The Makefile creates missing secret files automatically.

Relevant files:

- `secrets/wp_admin_password.txt`: WordPress administrator password
- `secrets/wp_user_password.txt`: WordPress regular user password
- `secrets/db_password.txt`: MariaDB WordPress user password
- `secrets/db_root_password.txt`: MariaDB root password

The WordPress administrator username is configured in `srcs/.env` as `WP_ADMIN_USR`.

## Check services

List containers:

```sh
docker-compose -f ./srcs/docker-compose.yml ps
```

Check Docker network:

```sh
docker network ls
```

Check volumes:

```sh
docker volume ls
docker volume inspect wordpress mariadb
```

Check HTTPS from the VM:

```sh
curl -k -I https://mawako.42.fr
```
