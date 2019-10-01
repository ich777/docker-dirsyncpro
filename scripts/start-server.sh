#!/bin/bash
DL_V=$(echo "${DL_URL}" | cut -d '-' -f 2)
CUR_V="$(find $DATA_DIR -name dirsync-* | cut -d '-' -f 2)"

echo "---Checking for 'runtime' folder---"
if [ ! -d ${DATA_DIR}/runtime ]; then
	echo "---'runtime' folder not found, creating...---"
	mkdir ${DATA_DIR}/runtime
else
	echo "---'runtime' folder found---"
fi

echo "---Checking if Runtime is installed---"
if [ -z "$(find ${DATA_DIR}/runtime -name jre*)" ]; then
    if [ "${RUNTIME_NAME}" == "jre1.8.0_211" ]; then
    	echo "---Downloading and installing Runtime---"
		cd ${DATA_DIR}/runtime
		wget -qi ${RUNTIME_NAME} https://github.com/ich777/docker-minecraft-basic-server/raw/master/runtime/8u211.tar.gz
        tar --directory ${DATA_DIR}/runtime -xvzf ${DATA_DIR}/runtime/8u211.tar.gz
        rm -R ${DATA_DIR}/runtime/8u211.tar.gz
    else
    	if [ ! -d ${DATA_DIR}/runtime/${RUNTIME_NAME} ]; then
        	echo "---------------------------------------------------------------------------------------------"
        	echo "---Runtime not found in folder 'runtime' please check again! Putting server in sleep mode!---"
        	echo "---------------------------------------------------------------------------------------------"
        	sleep infinity
        fi
    fi
else
	echo "---Runtime found---"
fi


echo "---Checking for DirSyncPro---"
if [ "$DL_V" == "$CUR_V" ]; then
	echo "---DirSyncPro found---"
elif [ -z "CUR_V" ]; then
	echo "---DirSyncPro not found, downloading...---"
    cd ${DATA_DIR}
    wget -q -O ${DL_URL}
    if [ ! -f ${DATA_DIR}/DirSyncPro-$DL_V-Linux.tar.gz ]; then
    	echo "-------------------------------------------------------"
    	echo "---Something went wrong couldn't download DirSyncPro---"
        echo "------Please make sure to put in the Linux version-----"
        echo "---------------in the DL_URL variable------------------"
        echo "----------Example: DirSyncPro-1.53.Linux.tar.gz--------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
	tar -xzf DirSyncPro-$DL_V-Linux.tar.gz
    if [ ! -d ${DATA_DIR}/DirSyncPro-$DL_V-Linux ]; then
    	echo "-------------------------------------------------------"
    	echo "---Something went wrong couldn't extract DirSyncPro----"
        echo "-----------Putting server into sleep mode--------------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
    touch dirsync-$DL_V
    rm -R DirSyncPro-$DL_V-Linux.tar.gz
    CUR_V="$(find $DATA_DIR -name dirsync-* | cut -d '-' -f 2)"
elif [ "$DL_V" != "$CUR_V" ]; then
	echo "-------------------------------------------"
    echo "---Version missmatch installed version: $CUR_V---"
    echo "------------Preferred versifon: $DL_V-----------"
    echo "----------Installing version: $DL_V-----------"
	echo "-------------------------------------------"
    cd ${DATA_DIR}
    rm -R DirSyncPro-$CUR_V-Linux
    rm -R dirsync-$CUR_V
    wget "${DL_URL}"
    if [ ! -f ${DATA_DIR}/DirSyncPro-$DL_V-Linux.tar.gz ]; then
    	echo "-------------------------------------------------------"
    	echo "---Something went wrong couldn't download DirSyncPro---"
        echo "------Please make sure to put in the Linux version-----"
        echo "---------------in the DL_URL variable------------------"
        echo "----------Example: DirSyncPro-1.53.Linux.tar.gz--------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
	tar -xzf DirSyncPro-$DL_V-Linux.tar.gz
    if [ ! -d ${DATA_DIR}/DirSyncPro-$DL_V-Linux ]; then
    	echo "-------------------------------------------------------"
    	echo "---Something went wrong couldn't extract DirSyncPro----"
        echo "-----------Putting server into sleep mode--------------"
        echo "-------------------------------------------------------"
        sleep infinity
    fi
    touch dirsync-$DL_V
    rm -R DirSyncPro-$DL_V-Linux.tar.gz
    CUR_V="$(find $DATA_DIR -name dirsync-* | cut -d '-' -f 2)"
fi


if [ "${REMOTE_TYPE}" == "smb" ]; then
	echo "---Mounting SAMBA share---"
    if [ ! -d /mnt/smb ]; then
    	mkdir /mnt/smb
    fi
	if sudo mount -t cifs -o username=${REMOTE_USER},password=${REMOTE_PWD},rw,uid=${UID},gid=${GID} //${REMOTE_DIR} /mnt/smb ; then
		echo "---Mounted ${REMOTE_DIR} to /mnt/smb---"
	else
		echo "---Couldn't mount ${REMOTE_DIR}---"
		sleep infinity
	fi
fi

if [ "${REMOTE_TYPE}" == "ftp" ]; then
    if [ ! -d /mnt/ftp ]; then
    	mkdir /mnt/ftp
    fi
	if curlftpfs ${REMOTE_USER}:${REMOTE_PWD}@${REMOTE_DIR} /mnt/ftp ; then
		echo "---Mounted ${REMOTE_DIR} to /mnt/ftp---"
	else
		echo "---Couldn't mount ${REMOTE_DIR}---"
		sleep infinity
	fi
fi

if [ "${REMOTE_TYPE}" == "webdav" ]; then
    if [ ! -d /mnt/webdav ]; then
    	mkdir /mnt/webdav
    fi
	if sudo mount -t davfs -o noexec username=${REMOTE_USER},password=${REMOTE_PWD},rw,uid=${UID},gid=${GID} ${REMOTE_DIR} /mnt/dav/ ; then
		echo "---Mounted ${REMOTE_DIR} to /mnt/webdav---"
	else
		echo "---Couldn't mount ${REMOTE_DIR}---"
		sleep infinity
	fi
fi

if [ "${REMOTE_TYPE}" == "local" ]; then
	echo "---Local mounting is selected, please mount your local path to the container---"
fi

echo "---Checking display configuration---"
if [ ! -f "${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties" ]; then
    cd ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/
    touch "dirsyncpro.properties"
	echo "dirsyncpro.window.last.geometry.y=0
dirsyncpro.window.last.geometry.x=0
dirsyncpro.window.last.geometry.height=768
dirsyncpro.window.last.geometry.width=1050" >> "${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties"
else
	if [ $(grep -e 'dirsyncpro.window.last.geometry.y=' ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties) != "dirsyncpro.window.last.geometry.y=0" ]; then
	sed -i "/dirsyncpro.window.last.geometry.y=/c\dirsyncpro.window.last.geometry.y=0" ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties
    fi
	if [ $(grep -e 'dirsyncpro.window.last.geometry.x=' ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties) != "dirsyncpro.window.last.geometry.x=0" ]; then
	sed -i "/dirsyncpro.window.last.geometry.x=/c\dirsyncpro.window.last.geometry.x=0" ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties
    fi
	if [ $(grep -e 'dirsyncpro.window.last.geometry.height=' ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties) != "dirsyncpro.window.last.geometry.height=768" ]; then
	sed -i "/dirsyncpro.window.last.geometry.height=/c\dirsyncpro.window.last.geometry.height=768" ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties
    fi
	if [ $(grep -e 'dirsyncpro.window.last.geometry.width=' ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties) != "dirsyncpro.window.last.geometry.width=1050" ]; then
	sed -i "/dirsyncpro.window.last.geometry.width=/c\dirsyncpro.window.last.geometry.width=1050" ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.properties
    fi
fi

echo "---Preparing Server---"
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
find /tmp -name ".X99*" -exec rm -f {} \;
chmod -R 770 ${DATA_DIR}

if [ "${CMD_MODE}" == "true" ]; then
	echo "-----------------------------------------"
    echo "---ATTENTION command line mode enabled---"
    echo "----starting sync of ${CMD_FILE}.dsc-----"
    echo "---in 30 seconds, please be sure that----"
    echo "----you put your cmd file in the main----"
    echo "---------directory of the Docker---------"
    echo "-----------------------------------------"
    sleep 10
    echo "---Starting in 20 seconds---"
    sleep 10
    echo "---Starting in 10 seconds---"
    sleep 5
    echo "---Starting in 5 seconds----"
    sleep 5
	if ${DATA_DIR}/runtime/${RUNTIME_NAME}/bin/java -jar ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.jar -nogui -quit /dirsyncpro/${CMD_FILE}.dsc ; then
		echo "---Sync ${CMD_FILE}.dsc finished---"
        sleep infinity
	else
		echo "---Couldn't find ${CMD_FILE}.dsc please be sure to put it in the main directory---"
		sleep infinity
	fi
else
	echo "---Starting Xvfb server---"
	screen -S Xvfb -L -Logfile ${DATA_DIR}/XvfbLog.0 -d -m /opt/scripts/start-Xvfb.sh
	sleep 5
	echo "---Starting x11vnc server---"
	screen -S x11vnc -L -Logfile ${DATA_DIR}/x11vncLog.0 -d -m /opt/scripts/start-x11.sh
	sleep 5

	echo "---Starting noVNC server---"
	websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 8080 localhost:5900
	sleep 5

	echo "---Starting DirSyncPro---"
	export DISPLAY=:99
	${DATA_DIR}/runtime/${RUNTIME_NAME}/bin/java -jar ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.jar
fi