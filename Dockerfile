FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV TZ=Europe/Rome
RUN apt-get -y install wget cifs-utils sudo curl curlftpfs davfs2 xvfb wmctrl x11vnc fluxbox screen novnc cryfs language-pack-en language-pack-ko language-pack-ja fonts-takao
ENV LANG=en_US.utf8
RUN sed -i '/    document.title =/c\    document.title = "DirSyncPro - noVNC";' /usr/share/novnc/include/ui.js

ENV DATA_DIR=/dirsyncpro
ENV REMOTE_DIR="192.168.1.1"
ENV REMOTE_TYPE="smb"
ENV REMOTE_USER=""
ENV REMOTE_PWD=""
ENV CRYFS=""
ENV CRYFS_PWD=""
ENV CRYFS_BLOCKSIZE=262144
ENV CRYFS_EXTRA_PARAMETERS=""
ENV RUNTIME_NAME="jre1.8.0_211"
ENV DL_URL="https://sourceforge.net/projects/directorysync/files/DirSync Pro (stable)/1.53/DirSyncPro-1.53-Linux.tar.gz"
ENV CMD_MODE=""
ENV CMD_FILE=""
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR
RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID dirsyncpro
RUN chown -R dirsyncpro $DATA_DIR

RUN ulimit -n 2048
RUN echo "dirsyncpro ALL=(root) NOPASSWD:/bin/mount" >> /etc/sudoers

ADD /scripts/ /opt/scripts/
RUN rm /usr/share/novnc/favicon.ico
COPY /dirsyncpro.ico /usr/share/novnc/favicon.ico
COPY /x11vnc /usr/bin/x11vnc
RUN chmod -R 770 /opt/scripts/
RUN chown -R dirsyncpro /opt/scripts
RUN chmod -R 770 /mnt
RUN chown -R dirsyncpro /mnt
RUN chmod 751 /usr/bin/x11vnc

USER dirsyncpro

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]