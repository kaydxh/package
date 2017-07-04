#!/bin/sh

#package prelogin

. utils.ac $1 $2 $3

function Compile_PreLogin_Proj() {
    cd $VRV_PRELOGIN_LOACAL_PATH

    echo " start make prelogin in Time: $(date +%F-%T) " > $PRELOGIN_LOG_INFO_LOCAL_PATH 2>&1
    bash $VRV_PRELOGIN_LOACAL_PATH/makefile >> $PRELOGIN_LOG_INFO_LOCAL_PATH 2>&1
    [ $? -ne 0 ] && {
        echo " make prelogin project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    [ ! -d $OUT_LOCAL_PRELOGIN_PATH ] && {
        mkdir -p $OUT_LOCAL_PRELOGIN_PATH
    }

    rm -rf $OUT_LOCAL_PRELOGIN_PATH/*

    mv $VRV_PRELOGIN_LOACAL_PATH/$PRELOGIN_EXEC_NAME $OUT_LOCAL_PRELOGIN_PATH/prelogin
    cp -rf $VRV_PRELOGIN_CONFIG_LOACAL_PATH/* $OUT_LOCAL_PRELOGIN_PATH
}

function Commit_PreLogin_Exec() {
    CreateRemotePath
    scp -r -P 10022 $OUT_LOCAL_PRELOGIN_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit prelogin exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } || {
        echo " commit prelogin exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}

[ ! -d $VRV_PRELOGIN_LOACAL_PATH ] && {
    mkdir -p $VRV_PRELOGIN_LOACAL_PATH
}

    cd $VRV_PRELOGIN_LOACAL_PATH

    UpdateProj
    echo "svn update prelogin project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH 2>&1

    Compile_PreLogin_Proj
    Commit_PreLogin_Exec
