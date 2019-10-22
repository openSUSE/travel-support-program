FROM opensuse/leap:42.3

RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  ruby ruby-devel ruby2.1-rubygem-bundler libxml2-devel libxslt-devel \
  postgresql-devel sqlite3-devel libqt4-devel libmysqlclient-devel libQtWebKit-devel \
  gcc gcc-c++ make tar gzip patch timezone && \
  zypper clean -a

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundle install

CMD ["rails", "server", "-b", "0.0.0.0"]
