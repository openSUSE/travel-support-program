FROM opensuse/leap:15.4

# This includes several packages (like Firefox, xvfb or liberation-fonts)
# That are only needed to run the automated tests and wouldn't be relevant
# in a production environment.
RUN zypper ar https://download.opensuse.org/repositories/devel:/languages:/ruby/15.4/ ruby && \
    zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
           ruby2.7 ruby2.7-devel libxml2-devel libxslt-devel chromium \
           postgresql-devel sqlite3-devel libmariadb-devel unzip wget \
           which liberation-fonts gcc gcc-c++ make tar gzip patch timezone && \
    zypper clean -a && \
    gem.ruby2.7 install bundler -v 1.17.3

RUN wget https://chromedriver.storage.googleapis.com/107.0.5304.62/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundler.ruby2.7 _1.17.3_ install

CMD ["rails", "server", "-b", "0.0.0.0"]
