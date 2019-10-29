FROM opensuse/leap:15.1

RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  ruby ruby-devel ruby2.5-rubygem-bundler libxml2-devel libxslt-devel \
  postgresql-devel sqlite3-devel libmariadb-devel \
  libQt5WebKit5 libQt5WebKit5-devel libQt5WebKitWidgets5 libQt5WebKitWidgets-devel \
  xvfb-run which liberation-fonts gcc gcc-c++ make tar gzip patch timezone && \
  zypper clean -a

RUN mkdir /app
WORKDIR /app
COPY . /app
ENV QMAKE=/usr/bin/qmake-qt5
RUN bundle install

CMD ["rails", "server", "-b", "0.0.0.0"]
