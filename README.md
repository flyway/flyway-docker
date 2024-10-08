# Flyway Open Source Docker images

This is the repository for [Flyway Command-line⁠](https://documentation.red-gate.com/fd/welcome-to-flyway-184127914.html) Open Source images. 

For the officially certified Redgate Flyway Docker images, use [Redgate/Flyway](https://hub.docker.com/r/redgate/flyway/) on Dockerhub, which works across the complete range of Flyway editions, including Community, Teams and Enterprise.

[Redgate/Flyway](https://hub.docker.com/r/redgate/flyway/) also provides compatibility with [Flyway Pipelines](https://flyway.red-gate.com/pipelines). Flyway Pipelines will help you gain centralized visibility of the state of your database deployments across projects so you can see what has been deployed, when and where for easy tracking.

## Suggested Project Structure

To make it easy to run Flyway the way you want to, you can use the following folders in your Flyway project

Volume            | Usage
------------------|------
`/flyway/conf`    | Directory containing a `flyway.conf/toml` [configuration file](https://documentation.red-gate.com/fd/configuration-files-224003079.html)
`/flyway/drivers` | Directory containing the [JDBC driver for your database](https://documentation.red-gate.com/fd/command-line-184127404.html#jdbc-drivers)
`/flyway/sql`     | The SQL files that you want Flyway to use (for [SQL-based migrations](https://documentation.red-gate.com/fd/migrations-184127470.html#sql-based-migrations))
`/flyway/jars`    | The jars files that you want Flyway to use (for [Java-based migrations](https://documentation.red-gate.com/fd/migrations-184127470.html#java-based-migrations))

## Getting started

The easiest way to get started is simply to test the default image by running

`docker run --rm flyway/flyway`

This will give you Flyway Command-line's usage instructions.

To do anything useful however, you must pass the arguments that you need to the image. For example:

`docker run --rm flyway/flyway -url=jdbc:sqlite:dev.db info`

Note that the syntax for **flyway/flyway:\*-azure** is slightly different in order to be compatible with Azure Pipelines
agent job requirements. As it does not define an entrypoint, you need to explicitly add the `flyway` command. For example:

`docker run --rm flyway/flyway:latest-azure flyway`

## Adding SQL files

To add your own SQL files, place them in a directory, mount it and point flyway at it using the [`workingDirectory`](https://documentation.red-gate.com/fd/working-directory-224919763.html) parameter.

### Example

Create a new `/sql` directory in your project folder and add a file named `V1__Initial.sql` with following contents:

```sql
CREATE TABLE MyTable (
    MyColumn VARCHAR(100) NOT NULL
);
```

Now run the image with the volume mapped:

`docker run --rm -v /absolute/path/to/my/project_folder:/flyway/project flyway/flyway -url=jdbc:sqlite:dev.db -workingDirectory="project" migrate`

## Adding a config file

If you prefer to store arguments in a config file you can put that in your project folder.

### Example

Create a file named `flyway.toml` with the following contents:

```
[environments.development]
url = "jdbc:sqlite:/flyway/project/dev.db"
user= "admin"
password = "password1"

[flyway]
environment = "development"
```

Now run the image with that volume mapped as well:

`docker run --rm -v /absolute/path/to/my/project_folder:/flyway/project flyway/flyway migrate -workingDirectory="project"`

## Adding a JDBC driver

If your database driver is not shipped by default (you can check the [official documentation here](https://documentation.red-gate.com/fd/supported-databases-184127454.html) to see if it is), or if you want to use a different or newer driver than the one included you can create a  `drivers/` folder in your project folder.

## Adding Java-based migrations and callbacks

To pass in Java-based migrations and callbacks you can use a `jars/` folder in your project directory and place them in there.

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
