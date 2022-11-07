FROM registry.opensuse.org/opensuse/infrastructure/tsp/containers/base:master

RUN gem.ruby2.7 install bundler -v 1.17.3

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundler.ruby2.7 _1.17.3_ install

CMD ["rails", "server", "-b", "0.0.0.0"]
