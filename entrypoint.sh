#!/bin/bash -e

export dataDir=/opt/mysql/data

groupadd -r mysql && useradd -r -g mysql mysql
chown -R mysql:mysql ${dataDir}

echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/my.cnf

su - mysql -c "/run.sh"

