#!/bin/bash
echo "---Checking for 'runtime' folder---"
if [ ! -d ${DATA_DIR}/runtime ]; then
	echo "---'runtime' folder not found, creating...---"
	mkdir ${DATA_DIR}/runtime
else
	echo "---"runtime" folder found---"
fi

echo "---Checking if Runtime is installed---"
if [ -z "$(find ${DATA_DIR} -name jre*)" ]; then
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


echo "---Sleep zZz---"
sleep infinity