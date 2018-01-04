# Official Flyway Docker images

[![Docker Auto Build](https://img.shields.io/docker/automated/boxfuse/flyway.svg?style=flat-square)][docker]

[docker]: https://hub.docker.com/r/boxfuse/flyway/

This is the official repository for [Flyway Command-line](https://flywaydb.org/documentation/commandline/) images.

## Supported Tags

The following tags are officially supported:

-	[`5.0.5`, `5.0`, `5`, `latest` (*Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/Dockerfile)
-	[`5.0.5-alpine`, `5.0-alpine`, `5-alpine`, `latest-alpine` (*alpine/Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/alpine/Dockerfile)
-	[`4.2.0`, `4.2`, `4` (*Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/Dockerfile)
-	[`4.2.0-alpine`, `4.2-alpine`, `4-alpine` (*alpine/Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/alpine/Dockerfile)

## Supported Volumes

To make it easy to run Flyway the way you want to, the following volumes are supported: 

Volume | Usage
-------|------
`/flyway/conf` | Directory containing a `flyway.conf` [configuration file](https://flywaydb.org/documentation/commandline/#configuration) 
`/flyway/drivers` | Directory containing the [JDBC driver for your database](https://flywaydb.org/documentation/commandline/#jdbc-drivers) 
`/flyway/sql` | The SQL files that you want Flyway to use (for [SQL-based migrations](https://flywaydb.org/documentation/migration/sql)) 
`/flyway/jars` | The jars files that you want Flyway to use (for [Java-based migrations](https://flywaydb.org/documentation/migration/java)) 

## Getting started

The easiest way to get started is simply to test the image by running

`docker run --rm boxfuse/flyway`

This will give you Flyway Command-line's usage instructions.

To do anything useful however, you must pass the arguments that you need to the image. For example:

`docker run --rm boxfuse/flyway -url=jdbc:h2:mem:test -user=sa info`

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
                                                             
`docker run --rm -v /my/sqldir:/flyway/sql boxfuse/flyway -url=jdbc:h2:mem:test -user=sa migrate`

## Adding a config file

If you prefer to store those arguments in a config file you can also do so using the `flyway/conf` volume.

### Example

Create a file named `flyway.conf` with the following contents:

```
flyway.url=jdbc:h2:mem:test
flyway.user=sa
```

Now run the image with that volume mapped as well:
            
`docker run --rm -v /my/sqldir:/flyway/sql -v /my/confdir:/flyway/conf boxfuse/flyway migrate`

## Adding a JDBC driver

Flyway ships by default with drivers for 

- SQL Server
- MySQL
- MariaDB
- PostgreSQL
- Sybase ASE
- H2
- HSQLDB
- Derby
- SQLite

If your database is not in this list, or if you want to ship a different or newer driver than the one included you
can do so using the `flyway/drivers` volume.

### Example

Create a directory and drop for example the Oracle JDBC driver (`ojdbc8.jar`) in there.

You can now let Flyway make use of it my mapping that volume as well:
            
`docker run --rm -v /my/sqldir:/flyway/sql -v /my/confdir:/flyway/conf -v /my/driverdir:/flyway/drivers boxfuse/flyway migrate`

## Adding Java-based migrations and callbacks

To pass in Java-based migrations and callbacks you can use the `flyway/jars` volume. 

### Example

Create a directory and drop for a jar with your Java-based migrations in there.

You can now let Flyway make use of it my mapping that volume as well:
            
`docker run --rm -v /my/sqldir:/flyway/sql -v /my/confdir:/flyway/conf -v /my/jardir:/flyway/jars boxfuse/flyway migrate`

## Docker Compose

To run both Flyway and the database that will be migrated in containers, you can use a `docker-compose.yml` file that
starts and links both containers.

### Example

```
version: '3'
services:
  flyway:
    image: boxfuse/flyway
    command: -url=jdbc:mysql://db -schemas=myschema -user=root -password=P@ssw0rd migrate
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

Run `docker-compose up -d db`, wait a minute for MySQL to be initialized (or tail logs with `docker-compose logs -f`) 
then run `docker-compose up flyway`.