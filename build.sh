#!/bin/sh

DOCKER_NEXTCLOUD_DIR="$(cd "$(dirname "$0")"||exit;pwd)"
echo "DOCKER_NEXTCLOUD_DIR: ${DOCKER_NEXTCLOUD_DIR}"

echo "start"
# clean directoris and files
if [ -e "${DOCKER_NEXTCLOUD_DIR}/html/nextcloud" ]; then
  rm -fr "${DOCKER_NEXTCLOUD_DIR}/html/nextcloud"
fi
if [ -e "${DOCKER_NEXTCLOUD_DIR}/mysql5.7/mysql_data" ]; then
  rm -fr "${DOCKER_NEXTCLOUD_DIR}/mysql5.7/mysql_data"
fi


# check and create directoris and files
if [ ! -e "${DOCKER_NEXTCLOUD_DIR}/.env" ]; then
  sh create_env.sh
fi
if [ ! -e "${DOCKER_NEXTCLOUD_DIR}/mysql5.7/docker-entrypoint-initdb.d" ]; then
  mkdir "${DOCKER_NEXTCLOUD_DIR}/mysql5.7/docker-entrypoint-initdb.d"
fi
if [ ! -e "${DOCKER_NEXTCLOUD_DIR}/php7.2/etc_apache2_sites-available/" ]; then
  mkdir "${DOCKER_NEXTCLOUD_DIR}/php7.2/etc_apache2_sites-available/"
fi


# create directoris and files
mkdir "${DOCKER_NEXTCLOUD_DIR}/mysql5.7/mysql_data"
touch "${DOCKER_NEXTCLOUD_DIR}/html/000-default.conf"
touch "${DOCKER_NEXTCLOUD_DIR}/html/php.ini-development"


echo "config files"
# get config files
docker run --user $(id -u):$(id -g) -it --rm \
 -v "${DOCKER_NEXTCLOUD_DIR}/html":/var/www/html php:7.2-apache \
 bash -c \
   'cp /usr/local/etc/php/php.ini-development /var/www/html/; \
    cp /etc/apache2/sites-available/000-default.conf /var/www/html/'


# create patch files for config
apach2_000_default_conf="${DOCKER_NEXTCLOUD_DIR}/html/000-default.conf"
cat << EOS > "${apach2_000_default_conf}.patch"
28a29,46
> 	<IfModule mod_headers.c>
> 		Header always set Referrer-Policy "no-referrer"
> 		Header always set Referrer-Policy "strict-origin"
> 	</IfModule>
> 	<IfModule mod_rewrite.c>
> 		Redirect 301 /.well-known/carddav /nextcloud/remote.php/dav
> 		Redirect 301 /.well-known/caldav /nextcloud/remote.php/dav
> 	</IfModule>
> 	<Directory /var/www/html/nextcloud/>
> 		Options +FollowSymlinks
> 		AllowOverride All
> 		<IfModule mod_dav.c>
> 			Dav off
> 		</IfModule>
> 		SetEnv HOME /var/www/html/nextcloud
> 		SetEnv HTTP_HOME /var/www/html/nextcloud
> 	</Directory>
> 
EOS

php_ini_development="${DOCKER_NEXTCLOUD_DIR}/html/php.ini-development"
cat << EOS > "${php_ini_development}.patch"
399c399
< memory_limit = 128M
---
> memory_limit = 512M
1760c1760
< ;opcache.enable=1
---
> opcache.enable=1
1763c1763
< ;opcache.enable_cli=0
---
> opcache.enable_cli=1
1766c1766
< ;opcache.memory_consumption=128
---
> opcache.memory_consumption=128
1769c1769
< ;opcache.interned_strings_buffer=8
---
> opcache.interned_strings_buffer=8
1773c1773
< ;opcache.max_accelerated_files=10000
---
> opcache.max_accelerated_files=10000
1791c1791
< ;opcache.revalidate_freq=2
---
> opcache.revalidate_freq=1
1798c1798
< ;opcache.save_comments=1
---
> opcache.save_comments=1
EOS


# patch and deploy
patch -s "${apach2_000_default_conf}" "${apach2_000_default_conf}.patch"
mv "${apach2_000_default_conf}" \
 "${DOCKER_NEXTCLOUD_DIR}/php7.2/etc_apache2_sites-available/"
rm "${apach2_000_default_conf}.patch"

patch -s "${php_ini_development}" "${php_ini_development}.patch"
mv "${php_ini_development}" \
 "${DOCKER_NEXTCLOUD_DIR}/php7.2/usr_local_etc_php/"
rm "${php_ini_development}.patch"

# exec docker-compose build
echo "docker-compose build"
cd "${DOCKER_NEXTCLOUD_DIR}"
docker-compose build

