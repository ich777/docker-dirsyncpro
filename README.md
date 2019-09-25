# DirSyncPro in Docker optimized for Unraid
This Docker will download and install DirSyncPro. You can sync your files to another offsite SMB or FTP share (more protocols like webdav planed for the future).
You can also use this tool to duplicate your files on the server to another directory.

Also there is a commandline mode without the GUI, please be sure that you put your config file in the main directory of the Docker and specify it.

Please also check out the Developers website of DirSyncPro: https://www.dirsyncpro.org/


## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for DirSyncPro | /dirsyncpro |
| REMOTE_DIR| The remote dir to connect | 192.168.1.1 |
| REMOTE_TYPE | Currently 'local', 'smb' and 'ftp' are available | local |
| REMOTE_USER | Remote username (must be provided - not for 'local') | username |
| REMOTE_PWD | Remote password (must be provided - not for 'local') | password |
| RUNTIME_NAME | Runtime name (must be profided) | jre1.8.0_211 |
| DL_URL | Download URL for DirSyncPro | https://sourceforge.net/projects/directorysync/files... |
| CMD_MODE | Set to 'true' if you want to use command line mode (otherwise blank) | |
| CMD_FILE | Specify the CMD file without the .dsc extension (only for CMD_MODE) | |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |


>**NOTE** This docker must be runned with the follwoing parameters '--cap-add SYS_ADMIN', '--cap-add DAC_READ_SEARCH', and '--privileged=true'

## Run example
```
docker run --name DirSyncPro -d \
    -p 8080:8080 \
    --env 'REMOTE_TYPE=smb' \
    --env 'REMOTE_DIR=192.168.1.1' \
    --env 'REMOTE_USER=username' \
    --env 'REMOTE_PWD=password' \
    --env 'RUNTIME_NAME=jre1.8.0_211 \
    --env 'DL_URL=https://sourceforge.net/projects/directorysync/files/DirSync Pro (stable)/1.53/DirSyncPro-1.53-Linux.tar.gz' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/dirsyncpro:/dirsyncpro \
    --privileged=true \
    --cap-add SYS_ADMIN \
    --cap-add DAC_READ_SEARCH \
    --restart=unless-stopped \
    ich777/steamcmd:latest
```


Please check also the Developers (O. Givi) website out: https://www.dirsyncpro.org/


#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/