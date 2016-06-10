FROM debian

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y mysql-server

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN apt-get install -y golang git ca-certificates gcc
ENV GOPATH /root
RUN go get bitbucket.org/liamstask/goose/cmd/goose

ADD . /db
RUN \
service mysql start && \
sleep 10 && \
while true; do mysql -e "SELECT 1" &> /dev/null; [ $? -eq 0 ] && break; echo -n "."; sleep 1; done && \
mysql -e "GRANT ALL ON *.* to 'root'@'%'; FLUSH PRIVILEGES;" && \
mysql -e "CREATE DATABASE mydb DEFAULT COLLATE utf8_general_ci;" && \
service mysql stop

EXPOSE 3306
CMD ["mysqld_safe"]
