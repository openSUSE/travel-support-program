# Using Docker to Develop TSP

This repository includes a `Dockerfile` and a set of `docker-compose` configuration examples in
order to simplify the process of setting up a development environment.

Given that you have `docker` and `docker-compose` installed, the process should be pretty
straighforward.

1. Select a `docker-compose` configuration file from the `docker/` directory and copy it as
   `docker-compose.yml`. For instance, to run the application using a PostgreSQL database:

        cp docker/docker-compose.development.postgresql docker-compose.yml

2. Uncomment the gem for your favorite database driver from the `Gemfile`.
3. Copy the database configuration from `docker/` for your database. For instance,
   to use PostgreSQL:

        cp docker/database.postgresql.yml config/database.yml

4. Build the image:

        docker-compose build

5. Now you should be able to set up the database:

        docker-compose run --rm web rake db:setup

   When using the mysql container, this fifth step may require that you have
   started the database container some seconds in advance, since the official
   mysql and mariadb containers need some time to initialize the system.

        docker-compose up --detach db

6. (Optional) Run the testsuite to find out whether the application works.

        docker-compose run --rm web xvfb-run -a rake spec

7. And, now, you can start the application:

        docker-compose up

For now on, you will need to rebuild the image whenever you change the `Gemfile` or `Gemfile.lock`
files.
