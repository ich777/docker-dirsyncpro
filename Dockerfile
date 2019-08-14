FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN apt-get -y install wget

ENV DATA_DIR=/dirsyncpro
ENV SERVER_DIR="/mnt/user"
ENV REMOTE_DIR="192.168.1.1"
ENV REMOTE_TYPE="smb"
ENV REMOTE_USER=""
ENV REMOTE_PWD=""
ENV JAVA_URL="https://github.com/ich777/docker-minecraft-basic-server/raw/master/runtime/8u211.tar.gz"
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR
RUN useradd -s /bin/bash --uid $UID --gid $GID dirsyncpro
RUN chown -R dirsyncpro $DATA_DIR

RUN ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
RUN chown -R dirsyncpro /opt/scripts

USER dirsyncpro

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]