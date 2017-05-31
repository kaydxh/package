#!/bin/sh

#package ap

. utils.ac $1 $2 $3

function Compile_AP2_Proj() {
    cd $VRV_AP2_LOCAL_PATH
    chmod a+x $VRV_AP2_LOCAL_PATH/ -R
    $VRV_AP2_LOCAL_PATH/gen-vrv-thrift.sh > $AP_LOG_INFO_LOCAL_PATH 2>&1

    cd $VRV_AP2_AP_LOCAL_PATH

    [ ! -d $VRV_AP2_BUILD_PATH ] && {
         mkdir -p $VRV_AP2_BUILD_PATH
    }

    cd $VRV_AP2_BUILD_PATH && rm -rf * 

    [ $? -ne 0 ] && {
        echo " make ap2.0 build env failed in Time: $(date +%F-%T) " >> $AP_LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 0
    } 

    echo " start make ap2.0 in Time: $(date +%F-%T) " >> $AP_LOG_INFO_LOCAL_PATH
    cmake $VRV_AP2_AP_LOCAL_PATH && make clean && make -j $COMPILE_CPU_NUMBER >> $AP_LOG_INFO_LOCAL_PATH 2>&1

    [ $? -ne 0 ] && {
        echo " make ap2.0 project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 0
    } 

    echo " make ap2.0 project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_AP2_PATH ] && {
        mkdir -p $OUT_LOCAL_AP2_PATH
    }

    #clear out dir 
    #rm -rf $OUT_LOCAL_AP2_PATH/*

    mv $VRV_AP2_BUILD_PATH/$AP_EXEC_NAME $OUT_LOCAL_AP2_PATH
    cp -rf $VRV_AP2_CONFIG_LOCAL_PATH/* $OUT_LOCAL_AP2_PATH
}

function Commit_AP2_Exec() {
    CreateRemotePath
    scp -r -P 10022 $OUT_LOCAL_AP2_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit ap2.0 exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
    } || {
        echo " commit ap2.0 exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}

[ ! -d $VRV_AP2_LOCAL_PATH ] && {
    mkdir -p $VRV_AP2_LOCAL_PATH
}

    cd $VRV_AP2_LOCAL_PATH
    UpdateProj

    UpdateThrift
    echo "svn update ap2.0 project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH

    Compile_AP2_Proj
    Commit_AP2_Exec





