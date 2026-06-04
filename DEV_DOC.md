# Developer Documentation

## Prerequisites

The project must run inside a virtual machine with Docker and `docker-compose` installed. The domain `mawako.42.fr` must resolve to the VM IP address.

The expected source layout is:

- `Makefile`: entrypoint for build and lifecycle commands
- `srcs/docker-compose.yml`: service, network, volume, and secret wiring
- `srcs/.env`: non-sensitive environment variables
- `srcs/requirements/nginx`: NGINX image and configuration script
- `srcs/requirements/wordpress`: WordPress + PHP-FPM image and configuration script
- `srcs/requirements/mariadb`: MariaDB image and configuration script
- `secrets/`: local ignored secret files

## Fresh setup

From the repository root, run:

```sh
make
```

The Makefile creates these directories if they do not exist:

```text
/home/mawako/data/wordpress
/home/mawako/data/mariadb
secrets/
```

It also creates missing secret files with random values. These files are ignored by git.

## Build and launch

The Makefile starts the project with:

```sh
docker-compose -f ./srcs/docker-compose.yml up -d
```

Each image is built from a local Dockerfile. The resulting image names match the service names: `nginx:42`, `wordpress:42`, and `mariadb:42`.

## Manage containers

Show running containers:

```sh
docker-compose -f ./srcs/docker-compose.yml ps
```

View logs:

```sh
docker-compose -f ./srcs/docker-compose.yml logs
```

Enter MariaDB with the WordPress database user:

```sh
docker exec -it mariadb mysql -uwpuser -p wordpress
```

The password is in `secrets/db_password.txt`.

## Manage volumes

The project uses two Docker named volumes:

- `wordpress`: mounted at `/var/www/html` in WordPress and NGINX
- `mariadb`: mounted at `/var/lib/mysql` in MariaDB

The named volumes are configured to store data under:

```text
/home/mawako/data/wordpress
/home/mawako/data/mariadb
```

Inspect them with:

```sh
docker volume inspect wordpress mariadb
```

## Persistence

WordPress files and database files live in Docker volumes, so container rebuilds do not delete the site content. To test persistence, edit a WordPress page, restart the VM, run `make`, and confirm that the edit remains visible.
