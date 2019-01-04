#!/bin/bash

## Nextcloudのアーカイブファイルダウンロードと展開
nextcloud_bz2="nextcloud-15.0.0.tar.bz2"
curl --silent -o "/var/www/${nextcloud_bz2}" \
  "https://download.nextcloud.com/server/releases/${nextcloud_bz2}"
tar -xjf "/var/www/${nextcloud_bz2}" -C /var/www/html
rm "/var/www/${nextcloud_bz2}"
chown -R www-data: /var/www/html/nextcloud/

## Nextcloudのインストール
## MYSQL_*, NC_* は docker-compose.yml用の.envに指定が必要
usermod -s /bin/bash www-data
su - www-data -c "/usr/local/bin/php /var/www/html/nextcloud/occ \
  maintenance:install \
   --database 'mysql' \
   --database-host 'mysql:3306' \
   --database-name ${MYSQL_DATABASE} \
   --database-user ${MYSQL_USER} \
   --database-pass ${MYSQL_PASSWORD} \
   --admin-user ${NC_ADMIN} \
   --admin-pass ${NC_ADMIN_PASS}"

## Nextcloud設定の変更
echo "NC_TRUSTED_DOMAIN: ${NC_TRUSTED_DOMAIN}"
nextcloud_config_patch="/var/www/html/nextcloud_config.php.patch"
cat << EOS > "${nextcloud_config_patch}"
7a8
>     1 => '${NC_TRUSTED_DOMAIN}',
12c13,14
<   'overwrite.cli.url' => 'http://localhost',
---
>   'overwrite.cli.url' => 'http://localhost:8080/nextcloud',
>   'htaccess.RewriteBase' => '/nextcloud',
EOS
su - www-data -c "/usr/bin/patch \
  /var/www/html/nextcloud/config/config.php \
  /var/www/html/nextcloud_config.php.patch"
rm /var/www/html/nextcloud_config.php.patch

## .htaccessファイルの再生成
su - www-data -c "/usr/local/bin/php /var/www/html/nextcloud/occ \
  maintenance:update:htaccess"
usermod -s /usr/sbin/nologin www-data

