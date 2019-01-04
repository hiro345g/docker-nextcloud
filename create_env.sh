#!/bin/sh
DOCKER_NEXTCLOUD_DIR="$(cd "$(dirname "$0")"||exit;pwd)"
env_file="${DOCKER_NEXTCLOUD_DIR}/.env"

echo "HOST_USER_ID=$(id -u)" > ${env_file}
echo "HOST_GROUP_ID=$(id -g)" >> ${env_file}
cat << EOS >> ${env_file}
MYSQL_ROOT_PASSWORD=adminpass
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=ncpass
NC_ADMIN=admin
NC_ADMIN_PASS=adminpass
NC_TRUSTED_DOMAIN=$(hostname -I | awk '{print $1}')
EOS

