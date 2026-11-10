# Using Docker to Develop TSP

This repository includes a `Dockerfile` and a set of `docker-compose` configuration examples in
order to simplify the process of setting up a development environment.

The openSUSE base image must provide the Ruby version required by `Gemfile`,
Node.js, Graphviz, and matching Chromium/ChromeDriver packages for the tests.

Given that you have `docker` and `docker-compose` installed, the process should be pretty
straighforward.

1. Select a `docker-compose` configuration file from the `docker/` directory and copy it as
   `docker-compose.yml`. For instance, to run the application using a PostgreSQL database:

        cp docker/docker-compose.development.postgresql.yml docker-compose.yml

2. Copy `config/site.example.yml` to `config/site.yml` and configure the application secrets.
3. Copy the database configuration from `docker/` for your database. For instance,
   to use PostgreSQL:

        cp docker/database.postgresql.yml config/database.yml

4. Build the image:

        CONTAINER_USERID=$(id -u) docker-compose build

5. Now you should be able to set up the database:

        docker-compose run --rm web bundler.ruby3.4 exec rake db:setup

   When using the mysql container, this fifth step may require that you have
   started the database container some seconds in advance, since the official
   mysql and mariadb containers need some time to initialize the system.

        docker-compose up --detach db

6. (Optional) Run the testsuite to find out whether the application works.

        docker-compose run --rm -e RAILS_ENV=test web bundler.ruby3.4 exec rake db:migrate
        docker-compose run --rm -e RAILS_ENV=test web bundler.ruby3.4 exec rspec

7. And, now, you can start the application:

        docker-compose up

For now on, you will need to rebuild the image whenever you change the `Gemfile` or `Gemfile.lock`
files.
