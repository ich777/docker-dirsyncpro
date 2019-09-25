#!/bin/bash
DL_V=$(echo "${DL_URL}" | cut -d '-' -f 2)
CUR_V="$(find $DATA_DIR -name dirsync-* | cut -d '-' -f 2)"

echo "---Sleep zZz---"
sleep infinity

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
	tar -xfv DirSyncPro-$DL_V-Linux.tar.gz
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
	tar -xfv DirSyncPro-$DL_V-Linux.tar.gz
    touch dirsync-$DL_V
    rm -R DirSyncPro-$DL_V-Linux.tar.gz
fi



if [ "${REMOTE_TYPE}" == "smb" ]; then
	echo "---Mounting SAMBA share---"
	if sudo mount -t cifs -o username=${REMOTE_USER},password=${REMOTE_PWD},rw //${REMOTE_DIR} /mnt ; then
    	echo "---Mounted ${REMOTE_DIR} to /mnt---"
    else
    	echo "---Couldn't mount ${REMOTE_DIR}---"
        sleep infinity
    fi
elif [ "${REMOTE_TYPE}" == "ftp" ];


fi

export DISPLAY=:99

screen -S Xvfb -L -Logfile ${SERVER_DIR}/XvfbLog.0 