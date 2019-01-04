#!/bin/sh

DOCKER_NEXTCLOUD_DIR="$(cd "$(dirname "$0")"||exit;pwd)"

cd "${DOCKER_NEXTCLOUD_DIR}"
. "${DOCKER_NEXTCLOUD_DIR}/.env"

docker network ls | grep -q docker-nextcloud_default && docker-compose down
docker-compose up -d

echo "check mysql database: ${MYSQL_DATABASE}"
sleep 15
until docker exec -it mysql bash -c "mysql -h localhost -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} -e 'select 1' > /dev/null 2>&1"; do
  >&2 echo "mysql is unavailable - sleeping"
  sleep 5
done

>&2 echo "mysql is up - executing command"

echo "check apache2 for php"
until docker-compose logs | grep -q 'apache2 -D FOREGROUND'; do
  >&2 echo "php is unavailable - sleeping"
  sleep 1
done

>&2 echo "php is up - executing command"

echo "exec install_nextcloud15.sh"
docker exec php bash -c "sh /var/www/html/install_nextcloud15.sh"
docker-compose down

