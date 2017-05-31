#!/bin/sh

#package apns

. utils.ac $1 $2 $3


#compile function
function Compile_APNS_Proj() {
    #cd $APNS_CONFIG_LOCAL_PATH
    #cp -rf $SRC_C_LOCAL_PATH/vrv-apns_new_server/*  $APNS_LOCAL_PATH
    cp -rf $APNS_CONFIG_LOCAL_PATH/$APNS_CONFIG_THRIFT_FILENAME $APNS_LOCAL_PATH

    [ ! -d $APNS_BUILD_LOCAL_PATH ] && {
        mkdir -p $APNS_BUILD_LOCAL_PATH
        #echo  $APNS_BUILD_LOCAL_PATH >> $APNS_LOG_INFO_LOCAL_PATH
    }

    cd $APNS_BUILD_LOCAL_PATH  && rm -rf * 

    [ $? -ne 0 ] && {
        echo " make apns build env failed in Time: $(date +%F-%T) " > $APNS_LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 0
    } 
    
    cd $APNS_LOCAL_PATH
    echo " start make apns in Time: $(date +%F-%T) " > $APNS_LOG_INFO_LOCAL_PATH

    chmod a+x $APNS_LOCAL_PATH/gencpp.sh
    bash $APNS_LOCAL_PATH/gencpp.sh >> $APNS_LOG_INFO_LOCAL_PATH 2>&1
    [ $? -ne 0 ] && {
        echo " apns project gencpp failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
    #    echo "0" > $EXEC_OUT_FILE_PATH
    #    exit 0
    }

    cd $APNS_BUILD_LOCAL_PATH 
    cmake $APNS_LOCAL_PATH && make clean && make -j $COMPILE_CPU_NUMBER >> $APNS_LOG_INFO_LOCAL_PATH 2>&1

    [ $? -ne 0 ] && {
        echo " make apns project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 0
    } 

    echo " make apns project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_APNS_PATH ] && {
        mkdir -p $OUT_LOCAL_APNS_PATH
    }

    mv $APNS_BUILD_LOCAL_PATH/$APNS_EXEC_NAME $OUT_LOCAL_APNS_PATH
    cp -rf $APNS_CONFIG_LOCAL_PATH/* $OUT_LOCAL_APNS_PATH
}

function Compile_APNS_Cfg_Proj() {
    cd $APNS_CONFIG_PROJ_LOCAL_PATH
    chmod a+x $APNS_CONFIG_PROJ_LOCAL_PATH/deps $APNS_CONFIG_PROJ_LOCAL_PATH/install
    $APNS_CONFIG_PROJ_LOCAL_PATH/install > $APNS_LOG_INFO_LOCAL_PATH 2>&1

    [ $? -ne 0 ] && {
        echo " make apnscfg project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 0
    } 

    echo " make apns_cfg project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_APNS_CFG_PATH ] && {
        mkdir -p $OUT_LOCAL_APNS_CFG_PATH
    }

    rm -rf $OUT_LOCAL_APNS_CFG_PATH/*

    mv $APNS_CONFIG_PROJ_LOCAL_PATH/bin/$APNS_CFG_EXEC_NAME $OUT_LOCAL_APNS_CFG_PATH
    cp -rf $APNS_CFG_CONFIG_LOCAL_PATH/* $OUT_LOCAL_APNS_CFG_PATH
}

function Commit_APNS_Exec() {
    CreateRemotePath
    scp -r -P 10022  $OUT_LOCAL_APNS_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit apns exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
    } || {
        echo " commit apns exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}

function Commit_APNS_Cfg_Exec() {
    CreateRemotePath
    scp -r -P 10022 $OUT_LOCAL_APNS_CFG_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit apns_cfg exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
    } || {
        echo " commit apns_cfg exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}

[ ! -d $APNS_BASE_LOCAL_PATH ] && {
    mkdir -p $APNS_BASE_LOCAL_PATH
}

    cd $APNS_BASE_LOCAL_PATH

    UpdateProj
    echo "svn update apns project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH
    Compile_APNS_Proj
    Commit_APNS_Exec

    #add apns_cfg
    cd $APNS_CONFIG_PROJ_LOCAL_PATH
    echo "svn update apns_cfg project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH
    Compile_APNS_Cfg_Proj
    Commit_APNS_Cfg_Exec
