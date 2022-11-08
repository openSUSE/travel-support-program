FROM registry.opensuse.org/opensuse/infrastructure/tsp/containers/base:main
ARG CONTAINER_USERID

# Configure our user
RUN usermod -u $CONTAINER_USERID tsp

WORKDIR /app

RUN gem.ruby2.7 install bundler -v 1.17.3
RUN gem.ruby2.7 install mini_racer -v 0.6.3

# Configure our bundle
# ENV BUNDLE_FORCE_RUBY_PLATFORM=true
RUN bundler.ruby2.7 _1.17.3_  config build.ffi --enable-system-libffi; \
    bundler.ruby2.7 _1.17.3_  config build.nokogiri --use-system-libraries; \
    bundler.ruby2.7 _1.17.3_  config build.sassc --disable-march-tune-native; \
    bundler.ruby2.7 _1.17.3_  config build.nio4r --with-cflags='-Wno-return-type'

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN bundler.ruby2.7 _1.17.3_ install --jobs=3 --retry=3

RUN chown -R tsp /app

# Now do the rest as the user with the same ID as the user who
# builds this container
USER tsp

CMD ["rails", "server", "-b", "0.0.0.0"]
