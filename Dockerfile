FROM opensuse/leap:15.4

# This includes several packages (like WebKit, xvfb or liberation-fonts)
# That are only needed to run the automated tests and wouldn't be relevant
# in a production environment.
RUN zypper ar https://download.opensuse.org/repositories/devel:/languages:/ruby/15.4/ ruby && \
  zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  ruby2.7 ruby2.7-devel libxml2-devel libxslt-devel \
  postgresql-devel sqlite3-devel libmariadb-devel \
  libQt5WebKit5 libQt5WebKit5-devel libQt5WebKitWidgets5 libQt5WebKitWidgets-devel \
  xvfb-run which liberation-fonts gcc gcc-c++ make tar gzip patch timezone && \
  zypper clean -a && \
  gem.ruby2.7 install bundler -v 1.17.3

RUN mkdir /app
WORKDIR /app
COPY . /app
ENV QMAKE=/usr/bin/qmake-qt5
RUN bundler.ruby2.7 _1.17.3_ install

CMD ["rails", "server", "-b", "0.0.0.0"]
