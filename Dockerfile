FROM opensuse/leap:15.2

# This includes several packages (like firefox, xvfb or liberation-fonts)
# That are only needed to run the automated tests and wouldn't be relevant
# in a production environment.
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  ruby ruby-devel "rubygem(bundler)" libxml2-devel libxslt-devel \
  postgresql-devel sqlite3-devel libmariadb-devel MozillaFirefox \
  xvfb-run which liberation-fonts gcc gcc-c++ make tar gzip patch timezone git-core && \
  zypper clean -a

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundle install

CMD ["rails", "server", "-b", "0.0.0.0"]
