#!/bin/sh

#package ag

. utils.ac $1 $2 $3

function Compile_UpLoad_Proj() {
    cd $VRV_UPLOAD_LOCAL_PATH
    [ ! -d $VRV_UPLOAD_BUILD_PATH ] && {
         mkdir -p $VRV_UPLOAD_BUILD_PATH
    }

    cd $VRV_UPLOAD_BUILD_PATH && rm -rf * 

    [ $? -ne 0 ] && {
        echo " make upload build env failed in Time: $(date +%F-%T) " > $UPLOAD_LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    echo " start make upload in Time: $(date +%F-%T) " > $UPLOAD_LOG_INFO_LOCAL_PATH 2>&1
    cmake $VRV_UPLOAD_LOCAL_PATH && make clean && make -j $COMPILE_CPU_NUMBER >> $UPLOAD_LOG_INFO_LOCAL_PATH 2>&1

    [ $? -ne 0 ] && {
        echo " make upload project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    echo " make upload project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_UPLOAD_PATH ] && {
        mkdir -p $OUT_LOCAL_UPLOAD_PATH
    }

    rm -rf $OUT_LOCAL_UPLOAD_PATH/*

    mv $VRV_UPLOAD_BUILD_PATH/$UPLOAD_EXEC_NAME $OUT_LOCAL_UPLOAD_PATH/upload
    cp -rf $VRV_UPLOAD_CONFIG_PATH $OUT_LOCAL_UPLOAD_PATH
}

function Commit_UpLoad_Exec() {
    CreateRemotePath
    scp -r -P 10022 $OUT_LOCAL_UPLOAD_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit upload exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } || {
        echo " commit upload exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}


[ ! -d $VRV_UPLOAD_LOCAL_PATH ] && {
    mkdir -p $VRV_UPLOAD_LOCAL_PATH
}

    cd $VRV_UPLOAD_LOCAL_PATH

    UpdateProj
    echo "svn update upload project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH 2>&1

    Compile_UpLoad_Proj
    Commit_UpLoad_Exec
