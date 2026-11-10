FROM registry.opensuse.org/opensuse/infrastructure/tsp/containers/base:main
ARG CONTAINER_USERID=1000

# Configure our user
RUN usermod -u "$CONTAINER_USERID" tsp

WORKDIR /app

# Configure our bundle
ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN gem.ruby3.4 install bundler --version "$(tail -n 1 Gemfile.lock | tr -d ' ')" --no-document
RUN bundler.ruby3.4 install --jobs=3 --retry=3

RUN chown -R tsp /app

# Now do the rest as the user with the same ID as the user who
# builds this container
USER tsp

CMD ["bundler.ruby3.4", "exec", "rails", "server", "-b", "0.0.0.0"]
