# Official Flyway Docker images

[![Docker Auto Build](https://img.shields.io/docker/cloud/automated/flyway/flyway)][docker]

[docker]: https://hub.docker.com/r/flyway/flyway/
[docker]: https://hub.docker.com/r/flyway/flyway-azure/

This is the official repository for [Flyway Command-line](https://flywaydb.org/documentation/commandline/) images.

## Which image should I use?

There are two families of images:

- **flyway/flyway** - this image is the basic Flyway command line application, and should be your default choice.
- **flyway/flyway-azure** - this image is suitable for use in Azure Pipelines agent jobs.

## Supported Tags

The following tags are officially supported:

-	[`7.9.1`, `7.9`, `7`, `latest` (*Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/Dockerfile)
-	[`7.9.1-alpine`, `7.9-alpine`, `7-alpine`, `latest-alpine` (*alpine/Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/alpine/Dockerfile)

The **flyway-azure** image *only* supports alpine versions.

## Supported Volumes

To make it easy to run Flyway the way you want to, the following volumes are supported:

Volume | Usage
-------|------
`/flyway/conf` | Directory containing a `flyway.conf` [configuration file](https://flywaydb.org/documentation/commandline/#configuration)
`/flyway/drivers` | Directory containing the [JDBC driver for your database](https://flywaydb.org/documentation/commandline/#jdbc-drivers)
`/flyway/sql` | The SQL files that you want Flyway to use (for [SQL-based migrations](https://flywaydb.org/documentation/migration/sql))
`/flyway/jars` | The jars files that you want Flyway to use (for [Java-based migrations](https://flywaydb.org/documentation/migration/java))

### Flyway Edition

You can switch between the various Flyway editions by setting the `FLYWAY_EDITION` environment variable to any of the following values:

Value | Description
------|------
`community` | Select the Flyway Community Edition (default)
`pro` | Select the Flyway Pro (v6) Edition
`enterprise` | Select the Flyway Enterprise (v6) / Teams (v7) Edition

## Getting started

The easiest way to get started is simply to test the default image by running

`docker run --rm flyway/flyway`

This will give you Flyway Command-line's usage instructions.

To do anything useful however, you must pass the arguments that you need to the image. For example:

`docker run --rm flyway/flyway -url=jdbc:h2:mem:test -user=sa info`

Note that the syntax for **flyway/flyway-azure** is slightly different in order to be compatible with Azure Pipelines
agent job requirements. As it does not define an entrypoint, you need to explicitly add the `flyway` command. For example:

`docker run --rm flyway/flyway-azure:latest-alpine flyway`

## Adding SQL files

To add your own SQL files, place them in a directory and mount it as the `flyway/sql` volume.

### Example

Create a new directory and add a file named `V1__Initial.sql` with following contents:

```
CREATE TABLE MyTable (
    MyColumn VARCHAR(100) NOT NULL
);

```

Now run the image with the volume mapped:

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql flyway/flyway -url=jdbc:h2:mem:test -user=sa migrate`

## Adding a config file

If you prefer to store those arguments in a config file you can also do so using the `flyway/conf` volume.

### Example

Create a file named `flyway.conf` with the following contents:

```
flyway.url=jdbc:h2:mem:test
flyway.user=sa
```

Now run the image with that volume mapped as well:

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql -v /absolute/path/to/my/confdir:/flyway/conf flyway/flyway migrate`

## Adding a JDBC driver

Flyway ships by default with drivers for

- Aurora MySQL
- Aurora PostgreSQL
- CockroachDB
- Derby
- Firebird
- H2
- HSQLDB
- MariaDB
- MySQL
- Percona XtraDB Cluster
- PostgreSQL
- SQL Server
- SQLite
- Sybase ASE

If your database is not in this list, or if you want to ship a different or newer driver than the one included you can do so using the `flyway/drivers` volume.

### Example

Create a directory and drop for example the Oracle JDBC driver (`ojdbc8.jar`) in there.

You can now let Flyway make use of it my mapping that volume as well:

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql -v /absolute/path/to/my/confdir:/flyway/conf -v /absolute/path/to/my/driverdir:/flyway/drivers flyway/flyway migrate`

## Adding Java-based migrations and callbacks

To pass in Java-based migrations and callbacks you can use the `flyway/jars` volume.

### Example

Create a directory and drop for a jar with your Java-based migrations in there.

You can now let Flyway make use of it my mapping that volume as well:

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql -v /absolute/path/to/my/confdir:/flyway/conf -v /absolute/path/to/my/jardir:/flyway/jars flyway/flyway migrate`

## Docker Compose

To run both Flyway and the database that will be migrated in containers, you can use a `docker-compose.yml` file that
starts and links both containers.

### Example

```
version: '3'
services:
  flyway:
    image: flyway/flyway
    command: -url=jdbc:mysql://db -schemas=myschema -user=root -password=P@ssw0rd -connectRetries=60 migrate
    volumes:
      - .:/flyway/sql
    depends_on:
      - db
  db:
    image: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=P@ssw0rd
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    ports:
      - 3306:3306
```

Run `docker-compose up`, this will start both Flyway and MySQL. Flyway will automatically wait for up to one minute for MySQL to be initialized before it begins to migrate the database.
