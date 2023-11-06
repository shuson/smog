FROM centos:7.9.2009

ENV TZ=Asia/Singapore
RUN yum install -y epel-release https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm && yum install -y --setopt=tsflags=nodocs nginx redis mariadb-devel python36 python36-devel openldap-devel supervisor git gcc wget unzip net-tools sshpass rsync sshfs && yum -y clean all --enablerepo='*'

RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir \
    gunicorn \
    mysqlclient \
    cryptography==36.0.2 \
    apscheduler==3.7.0 \
    asgiref==3.2.10 \
    Django==2.2.28 \
    channels==2.3.1 \
    channels_redis==2.4.1 \
    paramiko==2.11.0 \
    django-redis==4.10.0 \
    requests==2.22.0 \
    GitPython==3.0.8 \
    python-ldap==3.4.0 \
    openpyxl==3.0.3 \
    user_agents==2.2.0

RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN echo -e '\n# Source definitions\n. /etc/profile\n' >> /root/.bashrc
RUN mkdir -p /data/repos
RUN mkdir -p /data/spug/spug_web/build

# prepare code base build
# COPY spug_api /data/spug/spug_api
COPY spug_web/build /data/spug/spug_web/build

# RUN mkdir -p /data/spug/logs
# RUN touch /data/spug/logs/api.log
# RUN touch /data/spug/logs/ws.log
# RUN touch /data/spug/logs/worker.log
# RUN touch /data/spug/logs/monitor.log
# RUN touch /data/spug/logs/scheduler.log

COPY docker/init_spug /usr/bin/
COPY docker/nginx.conf /etc/nginx/
COPY docker/ssh_config /etc/ssh/
COPY docker/spug.ini /etc/supervisord.d/
COPY docker/redis.conf /etc/

COPY docker/entrypoint.sh /

VOLUME /data
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
