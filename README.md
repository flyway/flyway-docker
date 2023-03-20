# Official Flyway Community Docker images

[![Docker Auto Build](https://img.shields.io/docker/cloud/automated/flyway/flyway)][docker]

[docker]: https://hub.docker.com/r/flyway/flyway/

This is the official repository for [Flyway Command-line](https://flywaydb.org/documentation/usage/commandline/) images.

The Flyway Community images are available in [flyway/flyway](https://hub.docker.com/r/flyway/flyway/) on Dockerhub.

## Supported Tags

The following tags are officially supported:

- [`9.16.1`, `9.16`, `9`, `latest` (*Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/Dockerfile)
- [`9.16.1-alpine`, `9.16-alpine`, `9-alpine`, `latest-alpine` (*alpine/Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/alpine/Dockerfile)
- [`9.16.1-azure`, `9.16-azure`, `9-azure`, `latest-azure` (*azure/Dockerfile*)](https://github.com/flyway/flyway-docker/blob/master/azure/Dockerfile)

The **flyway/flyway:\*-azure** images *only* support alpine versions.

## Supported Volumes

To make it easy to run Flyway the way you want to, the following volumes are supported:

Volume            | Usage
------------------|------
`/flyway/conf`    | Directory containing a `flyway.conf` [configuration file](https://flywaydb.org/documentation/usage/commandline/#configuration)
`/flyway/drivers` | Directory containing the [JDBC driver for your database](https://flywaydb.org/documentation/usage/commandline/#jdbc-drivers)
`/flyway/sql`     | The SQL files that you want Flyway to use (for [SQL-based migrations](https://flywaydb.org/documentation/concepts/migrations#sql-based-migrations))
`/flyway/jars`    | The jars files that you want Flyway to use (for [Java-based migrations](https://flywaydb.org/documentation/concepts/migrations#java-based-migrations))

## Getting started

The easiest way to get started is simply to test the default image by running

`docker run --rm flyway/flyway`

This will give you Flyway Command-line's usage instructions.

To do anything useful however, you must pass the arguments that you need to the image. For example:

`docker run --rm flyway/flyway -url=jdbc:h2:mem:test -user=sa info`

Note that the syntax for **flyway/flyway:\*-azure** is slightly different in order to be compatible with Azure Pipelines
agent job requirements. As it does not define an entrypoint, you need to explicitly add the `flyway` command. For example:

`docker run --rm flyway/flyway:latest-azure flyway`

## Adding SQL files

To add your own SQL files, place them in a directory and mount it as the `flyway/sql` volume.

### Example

Create a new directory and add a file named `V1__Initial.sql` with following contents:

```sql
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

If your database driver is not shipped by default (you can check the official documentation [here](https://flywaydb.org/documentation/) to see if it is), or if you want to use a different or newer driver than the one included you can do so using the `flyway/drivers` volume.

### Example

Create a directory and drop for example the MySQL JDBC driver in there.

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
