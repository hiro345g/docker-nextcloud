FROM mysql:5.7
EXPOSE 3306

ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000


ADD ./my.cnf /etc/mysql/conf.d/my.cnf


RUN groupmod -g ${HOST_GROUP_ID} mysql && \
    usermod -u ${HOST_USER_ID} mysql


CMD ["mysqld"]
