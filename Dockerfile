FROM postgres:9.5
MAINTAINER Wesley Coppens <wesley@enelogic.com>

RUN apt-get update && apt-get install -y libxml2-dev \
  libxslt1-dev \
  python3 \
  python3-dev \
  python3-pip \
  daemontools \
  libevent-dev \
  lzop \
  pv \
  libffi-dev \
  libssl-dev \
  cron \
  supervisor && \
  pip3 install virtualenv

# Install WAL-E into a virtualenv
RUN virtualenv /var/lib/postgresql/wal-e &&\
  . /var/lib/postgresql/wal-e/bin/activate &&\
  pip3 install wal-e[aws] &&\
  ln -s -f /var/lib/postgresql/wal-e/bin/wal-e /usr/local/bin/wal-e

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/log/supervisor

RUN touch /firstrun

ADD 10-fix-acl.sh /docker-entrypoint-initdb.d/
ADD 20-setup-wal-e.sh /docker-entrypoint-initdb.d/
ADD supervisord.conf /etc/supervisor/supervisord.conf

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
