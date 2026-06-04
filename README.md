*This project has been created as part of the 42 curriculum by mawako.*

# Inception

## Description

Inception is a system administration project that builds a small Docker-based infrastructure inside a virtual machine. The stack contains three mandatory services: NGINX, WordPress with PHP-FPM, and MariaDB. Each service is built from its own Dockerfile and runs in its own container.

NGINX is the only public entrypoint and exposes HTTPS on port 443. WordPress communicates with MariaDB over a private Docker bridge network. Persistent data is stored in Docker named volumes for the WordPress files and the database.

## Project design

The project uses Docker Compose because the application is made of multiple containers that must be built, networked, started, stopped, and restarted together. The Makefile calls Docker Compose so the complete stack can be managed with one command.

The source tree is split by service under `srcs/requirements/`. Each service owns its Dockerfile and startup script. This keeps NGINX, WordPress, and MariaDB configuration independent and makes it clear which container is responsible for each process.

## Technical comparisons

### Virtual Machines vs Docker

A virtual machine runs a full guest operating system with its own kernel. Docker containers share the host kernel and isolate processes with namespaces and cgroups. Containers are lighter, start faster, and are easier to rebuild, while VMs provide heavier isolation at the cost of more CPU, memory, and disk usage.

### Secrets vs Environment Variables

Environment variables are convenient for non-sensitive configuration such as domain names and usernames, but they are easy to expose through process inspection, logs, or committed files. Docker secrets mount sensitive values as files inside the container. This project keeps passwords in local ignored files under `secrets/` and passes them as Docker secrets.

### Docker Network vs Host Network

A Docker bridge network isolates the containers from the host network while still allowing containers in the same network to communicate by service name. Host networking removes that isolation and exposes services directly on the host stack. This project uses a private bridge network named `inception`; `network: host`, `links`, and `--link` are not used.

### Docker Volumes vs Bind Mounts

Docker named volumes are managed by Docker and are suitable for persistent application data. Bind mounts directly expose a host path to a container and make the container depend more tightly on the host filesystem layout. This project mounts only named volumes in services. The named volumes are configured to keep their data under `/home/mawako/data` on the host, as required by the subject.

## Instructions

Before launching the project, make sure Docker and `docker-compose` are available and that `mawako.42.fr` points to the VM local IP address. For local testing, add it to `/etc/hosts` if needed.

Build and start the stack:

```sh
make
```

Stop containers:

```sh
make stop
```

Start stopped containers:

```sh
make start
```

Remove containers and the network:

```sh
make down
```

Check running containers:

```sh
make status
```

Open the website at:

```text
https://mawako.42.fr
```

The TLS certificate is self-signed, so the browser may show a warning.

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- Dockerfile reference: https://docs.docker.com/reference/dockerfile/
- WordPress CLI documentation: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.org/documentation/
- NGINX documentation: https://nginx.org/en/docs/

AI was used as a review assistant to compare the repository against the Inception subject, identify risky mismatches, and help draft documentation. All configuration and scripts must still be understood, tested, and defended by the project owner.
