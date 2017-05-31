#!/bin/sh

#package ag

. utils.ac $1 $2 $3

function Compile_Ag_Proj() {
    cd $VRV_AG_LOCAL_PATH
    chmod a+x $VRV_AG_LOCAL_PATH/deps $VRV_AG_LOCAL_PATH/install
    $VRV_AG_LOCAL_PATH/install > $AG_LOG_INFO_LOCAL_PATH 2>&1

    [ $? -ne 0 ] && {
        echo " make ag project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 0
    } 

    echo " make ag project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_AG_PATH ] && {
        mkdir -p $OUT_LOCAL_AG_PATH
    }

    rm -rf $OUT_LOCAL_AG_PATH/*

    mv $VRV_AG_LOCAL_PATH/$AG_EXEC_NAME $OUT_LOCAL_AG_PATH/ag
    cp -rf $VRV_AG_CONFIG_LOACAL_PATH/* $OUT_LOCAL_AG_PATH
}

function Commit_Ag_Exec() {
    CreateRemotePath
    scp -r -P 10022 $OUT_LOCAL_AG_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit ag exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
    } || {
        echo " commit ag exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}

[ ! -d $VRV_AG_LOCAL_PATH ] && {
    mkdir -p $VRV_AG_LOCAL_PATH
}

    cd $VRV_AG_LOCAL_PATH
    UpdateProj

    UpdateThrift
    echo "svn update ag project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH\

    Compile_Ag_Proj
    Commit_Ag_Exec
