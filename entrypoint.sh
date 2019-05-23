#!/bin/bash

REDMINE_BASE=/opt/redmine/redmine-4.0.3

echo "production:
  adapter: postgresql
  database: ${PSQL_DB_NAME}
  host: ${PSQL_DB}
  username: ${PSQL_DB_USERNAME}
  password: ${PSQL_DB_USER_PASSWORD}" > config/database.yml

if [ ! -f /data/config/database.yml ]; then
	cp -pR ${REDMINE_BASE}/* /data/
fi

if [ -f /data/tmp/pids/server.pid ]; then
	rm /data/tmp/pids/server.pid 
fi

mkdir -p /data/gems
if [ ! -f /data/gems/2.3.0 ]; then
	cp -pR /var/lib/gems/2.3.0 /data/gems
	rm -Rf /var/lib/gems
fi
ln -s /data/gems /var/lib/gems

rm -Rf ${REDMINE_BASE}
ln -s /data ${REDMINE_BASE}

cd ${REDMINE_BASE}

case "$1" in
  run)
      bundle exec ruby /usr/bin/rails server webrick -e production
      ;;
  init)
      RAILS_ENV=production bundle exec rake db:migrate
      RAILS_ENV=production bundle exec rake redmine:load_default_data
      ;;
  *)
      exec "$@"
esac
