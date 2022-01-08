#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority
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
    if [ "${RUNTIME_NAME}" == "basicjre" ]; then
    	echo "---Downloading and installing Runtime---"
		cd ${DATA_DIR}/runtime
		if wget -q -nc --show-progress --progress=bar:force:noscroll https://github.com/ich777/runtimes/raw/master/jre/basicjre.tar.gz ; then
			echo "---Successfully downloaded Runtime!---"
		else
			echo "---Something went wrong, can't download Runtime, putting server in sleep mode---"
			sleep infinity
		fi
        tar --directory ${DATA_DIR}/runtime -xvzf ${DATA_DIR}/runtime/basicjre.tar.gz
        rm -R ${DATA_DIR}/runtime/basicjre.tar.gz
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
elif [ -z "$CUR_V" ]; then
	echo "---DirSyncPro not found, downloading...---"
    cd ${DATA_DIR}
    if wget -q -nc --show-progress --progress=bar:force:noscroll "${DL_URL}" ; then
    	echo "---Successfully downloaded DirSyncPro---"
    else
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
    rm -R DirSyncPro-$DL_V-Linux.tar.gz 2>/dev/null
    CUR_V="$(find $DATA_DIR -name dirsync-* | cut -d '-' -f 2)"
elif [ "$DL_V" != "$CUR_V" ]; then
	echo "-------------------------------------------"
    echo "---Version missmatch installed version: $CUR_V---"
    echo "------------Preferred versifon: $DL_V-----------"
    echo "----------Installing version: $DL_V-----------"
	echo "-------------------------------------------"
    cd ${DATA_DIR}
    rm -R DirSyncPro-$CUR_V-Linux 2>/dev/null
    rm -R dirsync-$CUR_V 2>/dev/null
    if wget -q -nc --show-progress --progress=bar:force:noscroll "${DL_URL}" ; then
    	echo "---Successfully downloaded DirSyncPro---"
    else
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
    rm -R DirSyncPro-$DL_V-Linux.tar.gz 2>/dev/null
    CUR_V="$(find $DATA_DIR -name dirsync-* | cut -d '-' -f 2)"
fi

if [ "${CRYFS}" == "true" ]; then
	export CRYFS_FRONTEND=noninteractive
	if [ ! -d ${DATA_DIR}/cryfs ]; then
  		mkdir ${DATA_DIR}/cryfs
    fi
	if [ ! -d /tmp/cryfs ]; then
  		mkdir /tmp/cryfs
    fi
	if [ -z "$CRYFS_PWD" ]; then
    	echo "----------------------------------------------"
    	echo "--------No CryFS password set, please---------"
        echo "---set a password and restart the container---"
        echo "----------------------------------------------"
        sleep infinity
    fi
    if [ "${REMOTE_TYPE}" == "smb" ]; then
		echo "----------------------------------------------------"
        echo "---SMB mounting inside the container is removed!----"
		echo "---Please mount your share through the Unassigned---"
		echo "---Devices Plugin and select the mode 'local' in----"
        echo "----the template and mount the share inside the ----"
		echo "---------------------container!---------------------"
		echo "----------------------------------------------------"
		sleep infinity
    fi
	
    if [ "${REMOTE_TYPE}" == "ftp" ]; then
        if [ ! -d /mnt/ftp ]; then
            mkdir /mnt/ftp
        fi
        if curlftpfs ${REMOTE_USER}:${REMOTE_PWD}@${REMOTE_DIR} /tmp/cryfs ; then
            echo "---Mounted ${REMOTE_DIR} to /mnt/ftp---"
        else
            echo "---Couldn't mount ${REMOTE_DIR}---"
            sleep infinity
        fi
		if echo "${CRYFS_PWD}" | cryfs -c /dirsyncpro/cryfs/cryfs.cfg --logfile /dirsyncpro/cryfs/cryfs.log --blocksize ${CRYFS_BLOCKSIZE} ${CRYFS_EXTRA_PARAMETERS} /tmp/cryfs/ /mnt/ftp/; then
            echo "---Starting CryFS encryption---"
        else
            echo "---Couldn't start CryFS encryption of ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi

    if [ "${REMOTE_TYPE}" == "webdav" ]; then
        if [ ! -d /mnt/webdav ]; then
            mkdir /mnt/webdav
        fi
        if echo "${REMOTE_PWD}" | sudo mount -t davfs -o noexec,username=${REMOTE_USER},rw,uid=${UID},gid=${GID} ${REMOTE_DIR} /tmp/webdav/ ; then
            echo "---Mounted ${REMOTE_DIR} to /mnt/webdav---"
        else
            echo "---Couldn't mount ${REMOTE_DIR}---"
            sleep infinity
        fi
        if echo "${CRYFS_PWD}" | cryfs -c /dirsyncpro/cryfs/cryfs.cfg --logfile /dirsyncpro/cryfs/cryfs.log --blocksize ${CRYFS_BLOCKSIZE} ${CRYFS_EXTRA_PARAMETERS} /tmp/cryfs/ /mnt/webdav/ ; then
            echo "---Starting CryFS encryption---"
        else
            echo "---Couldn't start CryFS encryption of ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi

    if [ "${REMOTE_TYPE}" == "local" ]; then
      if [ ! -d /mnt/local ]; then
          echo "------------------------------------------------------------------------"
          echo "--------Encryption enabled! Path '/mnt/local' not found, please---------"
          echo "---be sure to mount a volume to this path while encryption is enabled---"
          echo "------------------------------------------------------------------------"
          sleep infinity
      fi
		if echo "${CRYFS_PWD}" | cryfs -c /dirsyncpro/cryfs/cryfs.cfg --logfile /dirsyncpro/cryfs/cryfs.log --blocksize ${CRYFS_BLOCKSIZE} ${CRYFS_EXTRA_PARAMETERS} /tmp/cryfs/ /mnt/local/ ; then
            echo "---Starting CryFS encryption---"
        else
            echo "---Couldn't start CryFS encryption of ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi
else
    if [ "${REMOTE_TYPE}" == "smb" ]; then
		echo "----------------------------------------------------"
        echo "---SMB mounting inside the container is removed!----"
		echo "---Please mount your share through the Unassigned---"
		echo "---Devices Plugin and select the mode 'local' in----"
        echo "----the template and mount the share inside the ----"
		echo "---------------------container!---------------------"
		echo "----------------------------------------------------"
		sleep infinity
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
        if echo "${REMOTE_PWD}" | sudo mount -t davfs -o noexec,username=${REMOTE_USER},rw,uid=${UID},gid=${GID} ${REMOTE_DIR} /mnt/webdav/ ; then
            echo "---Mounted ${REMOTE_DIR} to /mnt/webdav---"
        else
            echo "---Couldn't mount ${REMOTE_DIR}---"
            sleep infinity
        fi
    fi

    if [ "${REMOTE_TYPE}" == "local" ]; then
        echo "---Local mounting is selected, please mount your local path to the container---"
    fi
fi

echo "---Preparing Server---"
export RUNTIME_NAME="$(ls -d ${DATA_DIR}/runtime/* | cut -d '/' -f4)"
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
chmod -R ${DATA_PERM} ${DATA_DIR}
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

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
    echo "---Starting TurboVNC server---"
    vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
    sleep 2
    echo "---Starting Fluxbox---"
    screen -d -m env HOME=/etc /usr/bin/fluxbox
    sleep 2
    echo "---Starting noVNC server---"
    websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}

	echo "---Starting DirSyncPro---"
	${DATA_DIR}/runtime/${RUNTIME_NAME}/bin/java -Dfile.encoding=UTF-8 -jar ${DATA_DIR}/DirSyncPro-$CUR_V-Linux/dirsyncpro.jar ${START_PARAMS}
fi