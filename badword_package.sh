#!/bin/sh

#package badword

. utils.ac $1 $2 $3

function Compile_BadWord_Proj() {
    cd $VRV_BADWORD_LOCAL_PATH
    chmod a+x $VRV_AP2_LOCAL_PATH/ -R
    $VRV_BADWORD_LOCAL_PATH/gen-vrv-thrift.sh > $BADWORD_LOG_INFO_LOCAL_PATH 2>&1

    [ ! -d $VRV_BADWORD_BUILD_PATH ] && {
         mkdir -p $VRV_BADWORD_BUILD_PATH
    }

    cd $VRV_BADWORD_BUILD_PATH && rm -rf * 

    [ $? -ne 0 ] && {
        echo " make badword build env failed in Time: $(date +%F-%T) " >> $BADWORD_LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    echo " start make badword in Time: $(date +%F-%T) " >> $BADWORD_LOG_INFO_LOCAL_PATH
    cmake $VRV_BADWORD_LOCAL_PATH && make clean && make -j $COMPILE_CPU_NUMBER >> $BADWORD_LOG_INFO_LOCAL_PATH 2>&1

    [ $? -ne 0 ] && {
        echo " make badword project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    echo " make badword project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_BADWORD_PATH ] && {
        mkdir -p $OUT_LOCAL_BADWORD_PATH
    }

    #clear out dir 
    rm -rf $OUT_LOCAL_BADWORD_PATH/*

    mv $VRV_BADWORD_BIN_PATH/$BADWORD_EXEC_NAME $OUT_LOCAL_BADWORD_PATH
    cp -rf $VRV_BADWORD_DOCS_LOCAL_PATH/* $OUT_LOCAL_BADWORD_PATH
    cp -rf $VRV_BADWORD_LIB_LOCAL_PATH/*  $OUT_LOCAL_BADWORD_PATH
}

function Commit_BadWord_Exec() {
    CreateRemotePath
    scp -r -P 10022 $OUT_LOCAL_BADWORD_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit badword exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } || {
        echo " commit badword exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}


[ ! -d $VRV_BADWORD_LOCAL_PATH ] && {
    mkdir -p $VRV_BADWORD_LOCAL_PATH
}

    cd $VRV_BADWORD_LOCAL_PATH
    UpdateProj

    UpdateThrift
    echo "svn update badword project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH\

    Compile_BadWord_Proj
    Commit_BadWord_Exec
