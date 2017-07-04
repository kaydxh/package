#!/bin/sh

#package ngxcfg

. utils.ac $1 $2 $3

function Commit_Ngx_Config_File() {
    CreateRemotePath
    rm -rf $VRV_NGX_CONFIG_FILE_LOCAL_DST_PATH
    cp -rf $VRV_NGX_CONFIG_FILE_LOCAL_PATH/nginx $VRV_NGX_CONFIG_FILE_LOCAL_DST_PATH

    #delete .svn
    find $VRV_NGX_CONFIG_FILE_LOCAL_DST_PATH -type d -name .s*    | xargs rm -rf
    #delete _bak
    find $VRV_NGX_CONFIG_FILE_LOCAL_DST_PATH -type d -name *_bak  | xargs rm -rf

    scp -r -P 10022 $VRV_NGX_CONFIG_FILE_LOCAL_DST_PATH/* $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit ngx config files failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } || {
        echo " commit ngx config files success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}

[ ! -d $VRV_NGX_CONFIG_FILE_LOCAL_PATH ] && {
    mkdir -p $VRV_NGX_CONFIG_FILE_LOCAL_PATH
}

    cd $VRV_NGX_CONFIG_FILE_LOCAL_PATH
    UpdateProj

    UpdateNgxHtml
    echo "svn update ngx config file to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH 2>&1

    Commit_Ngx_Config_File

