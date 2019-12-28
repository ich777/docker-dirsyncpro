FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	apt-get -y install --no-install-recommends sudo curl && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR=/dirsyncpro
ENV REMOTE_DIR="192.168.1.1"
ENV REMOTE_TYPE="smb"
ENV REMOTE_USER=""
ENV REMOTE_PWD=""
ENV CRYFS=""
ENV CRYFS_PWD=""
ENV CRYFS_BLOCKSIZE=262144
ENV CRYFS_EXTRA_PARAMETERS=""
ENV RUNTIME_NAME="basicjre"
ENV DL_URL="https://sourceforge.net/projects/directorysync/files/DirSync Pro (stable)/1.53/DirSyncPro-1.53-Linux.tar.gz"
ENV CMD_MODE=""
ENV CMD_FILE=""
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID dirsyncpro && \
	chown -R dirsyncpro $DATA_DIR && \
	ulimit -n 2048 && \
	echo "dirsyncpro ALL=(root) NOPASSWD:/bin/mount" >> /etc/sudoers

ADD /scripts/ /opt/scripts/
COPY /x11vnc /usr/bin/x11vnc
RUN chmod -R 770 /opt/scripts/ && \
	chown -R dirsyncpro /opt/scripts && \
	chmod -R 770 /mnt && \
	chown -R dirsyncpro /mnt && \
	chmod 751 /usr/bin/x11vnc

USER dirsyncpro

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]