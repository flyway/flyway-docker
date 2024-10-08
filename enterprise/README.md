# Official Redgate Flyway Docker images

This is the official repository for [Flyway Command-line](https://documentation.red-gate.com/fd/welcome-to-flyway-184127914.html) images.

These images work across the complete range of Redgate Flyway editions, including Community, Teams and Enterprise, as well as providing compatibility with [Flyway Pipelines](https://flyway.red-gate.com/pipelines). Flyway Pipelines will help you gain centralized visibility of the state of your database deployments across projects so you can see what has been deployed, when and where for easy tracking.

## Supported Volumes

To make it easy to run Flyway the way you want to, the following volumes are supported:

Volume            | Usage
------------------|------
`/flyway/conf`    | Directory containing a [configuration file](https://documentation.red-gate.com/fd/configuration-files-224003079.html)
`/flyway/drivers` | Directory containing the [JDBC driver for your database](https://documentation.red-gate.com/fd/command-line-184127404.html)
`/flyway/sql`     | The SQL files that you want Flyway to use (for [SQL-based migrations](https://documentation.red-gate.com/fd/migrations-184127470.html))
`/flyway/jars`    | The jar files that you want Flyway to use (for [Java-based migrations](https://documentation.red-gate.com/fd/migrations-184127470.html))

## Getting started

The easiest way to get started is simply to test the default image by running

`docker run --rm redgate/flyway`

This will give you Flyway Command-line's usage instructions.

To do anything useful however, you must pass the arguments that you need to the image. For example:

`docker run --rm redgate/flyway -licenseKey="FL01..." -url=jdbc:h2:mem:test -user=sa info`

Note that the syntax for **redgate/flyway:\*-azure** is slightly different in order to be compatible with Azure Pipelines
agent job requirements. As it does not define an entrypoint, you need to explicitly add the `flyway` command. For example:

`docker run --rm redgate/flyway:latest-azure flyway`

## Flyway Pipelines 

To learn more about Flyway Pipelines you can access our [official documentation](https://documentation.red-gate.com/fd/introducing-flyway-pipelines-251363987.html)

You can access the Flyway Pipelines service here:  https://flyway.red-gate.com/ 

To use Flyway Pipelines, you will need a [Personal Access Token](https://documentation.red-gate.com/fd/personal-access-tokens-251363983.html). 

### Example 

To use the Flyway service within this image, include the following: 
```
docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql -v /absolute/path/to/my/confdir:/flyway/conf redgate/flyway migrate –publishResults=true –email=<E-mailLinkedToRedgateAccount> -token=<InsertPATokenHere>
```

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

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql redgate/flyway -licenseKey="FL01..." -url=jdbc:h2:mem:test -user=sa migrate`

## Adding a config file

If you prefer to store those arguments in a config file you can also do so using the `flyway/conf` volume.

### Example

Create a file named `flyway.conf` with the following contents:

```
flyway.url=jdbc:h2:mem:test
flyway.user=sa
flyway.licenseKey=FL01...
```

Now run the image with that volume mapped as well:

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql -v /absolute/path/to/my/confdir:/flyway/conf redgate/flyway migrate`

## Adding a JDBC driver

If your database driver is not shipped by default (you can check the official documentation [here](https://documentation.red-gate.com/fd/flyway-cli-and-api-183306238.html) to see if it is), or if you want to use a different or newer driver than the one included you can do so using the `flyway/drivers` volume.

### Example

Create a directory and drop for example the MySQL JDBC driver in there.

You can now let Flyway make use of it my mapping that volume as well:

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql -v /absolute/path/to/my/confdir:/flyway/conf -v /absolute/path/to/my/driverdir:/flyway/drivers redgate/flyway migrate`

## Adding Java-based migrations and callbacks

To pass in Java-based migrations and callbacks you can use the `flyway/jars` volume.

### Example

Create a directory and drop for a jar with your Java-based migrations in there.

You can now let Flyway make use of it my mapping that volume as well:

`docker run --rm -v /absolute/path/to/my/sqldir:/flyway/sql -v /absolute/path/to/my/confdir:/flyway/conf -v /absolute/path/to/my/jardir:/flyway/jars redgate/flyway migrate`

## Docker Compose

To run both Flyway and the database that will be migrated in containers, you can use a `docker-compose.yml` file that
starts and links both containers.

### Example

```
version: '3'
services:
  flyway:
    image: redgate/flyway
    command: -licenseKey="FL01..." -url=jdbc:mysql://db -schemas=myschema -user=root -password=P@ssw0rd -connectRetries=60 migrate
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
