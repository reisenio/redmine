FROM debian:latest

RUN apt-get -y update \
  && apt-get -y  install gcc build-essential zlib1g zlib1g-dev zlibc ruby-zip libssl-dev libyaml-dev \
     libcurl4-openssl-dev ruby gem libapache2-mod-passenger apache2 apache2-dev libapr1-dev \
     libxslt1-dev checkinstall libxml2-dev ruby-dev libmagickwand-dev imagemagick rails wget gosu libpq-dev sudo

# Create redmine directory
RUN mkdir -p /opt/redmine 

# Uncompress redmine
RUN wget -q -O - http://www.redmine.org/releases/redmine-4.0.3.tar.gz | tar xvz --directory=/opt/redmine

# Cleanup
RUN apt-get -y remove wget \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/redmine/redmine-4.0.3

RUN echo "production:\n  adapter: postgresql\n  database: ${PSQL_DB_NAME}\n  host: ${PSQL_DB}\n  username: ${PSQL_DB_USERNAME}\n  password: ${PSQL_DB_USER_PASSWORD}" > config/database.yml

RUN useradd redmine -d /opt/redmine/redmine-4.0.3 -s /bin/bash \
  && chown -R redmine:redmine /opt/redmine/redmine-4.0.3

RUN bundle install \
  && gosu redmine bundle exec rake generate_secret_token

COPY entrypoint.sh /usr/sbin
RUN chmod 755 /usr/sbin/entrypoint.sh

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]







