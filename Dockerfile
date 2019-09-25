FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV TZ=Europe/Rome
RUN apt-get -y install wget cifs-utils sudo curl curlftpfs davfs2 xvfb wmctrl x11vnc fluxbox screen

ENV DATA_DIR=/dirsyncpro
ENV REMOTE_DIR="192.168.1.1"
ENV REMOTE_TYPE="smb"
ENV REMOTE_USER=""
ENV REMOTE_PWD=""
ENV RUNTIME_NAME="jre1.8.0_211"
ENV DL_URL="https://sourceforge.net/projects/directorysync/files/DirSync Pro (stable)/1.53/DirSyncPro-1.53-Linux.tar.gz"
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR
RUN chown -R root $DATA_DIR

RUN ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
RUN chown -R root /opt/scripts
RUN chmod -R 770 /mnt
RUN chown -R root /mnt

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]