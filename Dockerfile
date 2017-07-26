FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive

# ncurses-bin
COPY entrypoint.sh /usr/bin/
COPY run.sh /opt
COPY default_tables.sql /opt


RUN apt-get update && apt-get install -y \
    libaio1 wget bison cmake g++ libncurses5-dev libtool m4 automake\
    && apt-get autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \

    cd /opt && \
    wget -O mysql-src.tar.gz http://www.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.37.tar.gz/from/http://cdn.mysql.com/ --show-progress && \
    tar xzf mysql-src.tar.gz && unlink mysql-src.tar.gz && \
    mv mysql-5.6.37 mysql-src && \

     cd /opt/mysql-src && \
    cmake . -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DMYSQL_DATADIR=/opt/mysql/data \
    -DCMAKE_INSTALL_PREFIX=/opt/mysql \
    -DINSTALL_LAYOUT=STANDALONE -DENABLED_PROFILING=ON \
    -DMYSQL_MAINTAINER_MODE=OFF -DWITH_DEBUG=OFF \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DENABLED_LOCAL_INFILE=TRUE -DWITH_ZLIB=bundled && \
    make && make install && \

     cd /opt && wget -O pinba.tar.gz https://github.com/tony2001/pinba_engine/archive/RELEASE_1_2_0.tar.gz && \
    tar xzf pinba.tar.gz && unlink pinba.tar.gz && \
    cd pinba_engine-RELEASE_1_2_0 && \
    bash buildconf.sh && \
    ./configure \
    --with-mysql=/opt/mysql-src \
    --with-event=/usr \
    --libdir=/opt/mysql/lib/plugin && \
    make install && \

    rm -Rf /opt/mysql-src && rm -Rf /opt/pinba_engine-RELEASE_1_2_0 && \
  apt-get remove -y wget g++ libncurses5-dev libtool m4 automake && \
  apt-get autoclean && apt-get autoremove -y && \

  ln -s /usr/bin/entrypoint.sh /entrypoint.sh && chmod +x /usr/bin/entrypoint.sh && \
  ln -s /opt/run.sh /run.sh && chmod +x /opt/run.sh

VOLUME /opt/mysql/data

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3306
CMD ["mysqld"]