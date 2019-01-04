# Docker Nextcloud

開発用のNextcloudをdockerを使って用意することができます。動作確認にはUbuntu 18.04を使っています。


## 使い方

イメージのビルドをする build.sh とNextcloudのインストールをする install.sh のスクリプトを用意してあります。これらを実行します。必要な環境変数の値を持つ .envファイルを生成して、dockerイメージのビルドがされます。既存の .envファイルがある場合は、それを使います。後述するcreate_env.shの説明も参考にしてください。

なお、build.shを実行すると、既存のNextcloud、MySQLのDBは削除されます。また、.envファイルの生成もします。注意してください。.envの内容を変更してビルドするなどカスタマイズをしたい場合には、スクリプトの内容を参考にして適切な処理を実行するようにしてください。

```sh
$ sh build.sh
```
次にビルドしたイメージを使ってdockerコンテナを起動し、Nextcloudのインストールをします。apache2やmysqldが起動してからインストール処理を進める必要があるので、それぞれの起動チェックをしています。準備ができると、インストールが先に進みinstall_nextcloud15.shが実行されます。

```sh
$ sh install.sh
```

インストールができたら、docker-composeコマンドで起動(up)、停止(down)ができます。

```sh
$ docker-compose up -d
$ docker-compose down
```

docker-compose up をしたら、NextcloudのURLへブラウザでアクセスします。URLは下記になります。

- http://localhost:8080/nextcloud/
- http://<dockerホストのIPアドレス>:8080/nextcloud/

トップページはPHPの情報を表示するようになっています。

- http://localhost:8080/
- http://<dockerホストのIPアドレス>:8080/


## スクリプトについて

### create_env.sh

create_env.shはbuild.shで使われています。ここに記載されているMYSQL_で始まる環境変数の指定がMySQLで使われます。また、NC_で始まる環境変数の指定がNextcloudで使われます。使われている値を変更したい場合はbuild.shを実行する前にcreate_env.shを実行して.envファイルを作成して編集をします。

NC_TRUSTED_DOMAINはdockerホストのIPアドレスを使っています。他のPCからdockerホストへマシン名でアクセスできる環境の場合は、マシン名を指定することもできます。


### install_nextcloud15.sh

html/install_nextcloud15.sh はNextcloudのインストール用スクリプトです。phpコマンドによるoccコマンドを使ってインストールしています。


## ディレクトリ構成

ディレクトリ構成は次の通りです。build.shとinstall.shを実行すると、html/nextcloudにNextcloudがインストールされます。mysqlのデータはmysql5.7/mysql_dataに用意されます。

```
.
├── LICENSE
├── README.md
├── build.sh
├── create_env.sh
├── docker-compose.yml
├── html/
│   ├── index.php
│   └── install_nextcloud15.sh
├── install.sh
├── mysql5.7/
│   ├── Dockerfile
│   └── my.cnf
└── php7.2/
    ├── Dockerfile
    └── usr_local_etc_php/
        └── conf.d/
            ├── docker-php-ext-bcmath.ini
            ├── docker-php-ext-gd.ini
            ├── docker-php-ext-imagick.ini
            ├── docker-php-ext-intl.ini
            ├── docker-php-ext-mysqli.ini
            ├── docker-php-ext-pdo_mysql.ini
            └── docker-php-ext-zip.ini

```

