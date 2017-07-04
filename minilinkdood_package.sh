#!/bin/sh

. utils.ac $1 $2 $3

function Compile_Linkdood_Proj() {
	cd $VRV_MINILINKDOOD_LOCAL_PATH
	chmod a+x $VRV_MINILINKDOOD_LOCAL_PATH -R
	bash $VRV_MINILINKDOOD_LOCAL_PATH/gen-vrv-thrift.sh > $MINILINKDOOD_LOG_INFO_LOCAL_PATH 2>&1

	[ ! -d $VRV_LINKDOOD_BUILD_PATH ] && {
        mkdir -p $VRV_LINKDOOD_BUILD_PATH
    }

    cd $VRV_LINKDOOD_BUILD_PATH 
    rm -rf $VRV_LINKDOOD_BUILD_PATH/*

    [ $? -ne 0 ] && {
        echo " make linkdood build env failed in Time: $(date +%F-%T) " >> $MINILINKDOOD_LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    }

    echo " start make linkdood in Time: $(date +%F-%T) " >> $MINILINKDOOD_LOG_INFO_LOCAL_PATH
    cmake $VRV_MINILINKDOOD_LOCAL_PATH && make clean && make -j $COMPILE_CPU_NUMBER >> $MINILINKDOOD_LOG_INFO_LOCAL_PATH 2>&1
    [ $? -ne 0 ] && {
        echo " make linkdood project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    echo " make linkdood project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_LINKDOOD_PATH ] && {
        mkdir -p $OUT_LOCAL_LINKDOOD_PATH
    }

    rm -rf $OUT_LOCAL_LINKDOOD_PATH/*
    cp -rf $VRV_LINKDOOD_BIN_PATH/$LINKDOOD_EXEC_NAME $OUT_LOCAL_LINKDOOD_PATH/miniLinkdood
    cp -rf $VRV_LINKDOOD_CONFIG_LOCAL_PATH/* $OUT_LOCAL_LINKDOOD_PATH
}

function Compile_LinkdoodWeb_Proj() {
	cd $VRV_MINILINKDOOD_LOCAL_PATH
	chmod a+x $VRV_MINILINKDOOD_LOCAL_PATH -R

    echo " start make linkdoodweb in Time: $(date +%F-%T) " >> $MINILINKDOOD_LOG_INFO_LOCAL_PATH
    bash $VRV_MINILINKDOOD_LOCAL_PATH/gen-miniweb-thrift.sh >> $MINILINKDOOD_LOG_INFO_LOCAL_PATH 2>&1
    [ $? -ne 0 ] && {
        echo " make linkdoodweb project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    [ ! -d $VRV_LINKDOODWEB_BUILD_PATH ] && {
        mkdir -p $VRV_LINKDOODWEB_BUILD_PATH
    }

    rm -rf $VRV_LINKDOODWEB_BUILD_PATH/*

    cd $VRV_LINKDOODWEB_LOCAL_SRC_PATH
    bash $VRV_LINKDOODWEB_LOCAL_PATH/install.sh >> $MINILINKDOOD_LOG_INFO_LOCAL_PATH 2>&1

    [ $? -ne 0 ] && {
        echo " make miniLinkdoodWeb project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } 

    echo " make miniLinkdoodWeb project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_LINKDOODWEB_PATH ] && {
        mkdir -p $OUT_LOCAL_LINKDOODWEB_PATH
    }

    rm -rf $OUT_LOCAL_LINKDOODWEB_PATH/*

    cp -rf $VRV_LINKDOODWEB_BUILD_PATH/* $OUT_LOCAL_LINKDOODWEB_PATH
    mv $OUT_LOCAL_LINKDOODWEB_PATH/$LINKDOODWEB_EXEC_NAME $OUT_LOCAL_LINKDOODWEB_PATH/miniLinkdoodWeb
    cp -rf $VRV_LINKDOODWEB_CONFIG_PATH/* $OUT_LOCAL_LINKDOODWEB_PATH
}

function Compile_ApnsAgent() {
	cd $VRV_APNSAGENT_LOCAL_PATH
	chmod a+x $VRV_APNSAGENT_LOCAL_PATH/ -R
	bash $VRV_APNSAGENT_LOCAL_PATH/install >> $MINILINKDOOD_LOG_INFO_LOCAL_PATH 2>&1

	[ $? -ne 0 ] && {
        echo " make apnsAgent project failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 0
    } 

    echo " make apnsAgent project success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH

    [ ! -d $OUT_LOCAL_APNSAGENT_PATH ] && {
        mkdir -p $OUT_LOCAL_APNSAGENT_PATH
    }

    rm -rf $OUT_LOCAL_APNSAGENT_PATH/*
    cp -rf $VRV_APNSAGENT_LOCAL_PATH/src/$APNSAGENT_EXEC_NAME $OUT_LOCAL_APNSAGENT_PATH
    cp -rf $VRV_APNSAGENT_CONDIG_LOCAL_PATH/* $OUT_LOCAL_APNSAGENT_PATH
}

function Compile_MiniLinkdood_Proj() {
	Compile_Linkdood_Proj
	Compile_LinkdoodWeb_Proj
	Compile_ApnsAgent
}

function Commit_MiniLinkdood_Exec() {
    CreateRemotePath
    scp -r -P 10022 $OUT_LOCAL_MINILINKDOOD_PATH $COMMIT_REMOTE_USER@$COMMIT_REMOTE_IP_ADDR:$REMOTE_PATH
    [ $? -ne 0 ] && {
        echo " commit miniLinkdood exec failed in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "0" > $EXEC_OUT_FILE_PATH
        exit 1
    } || {
        echo " commit miniLinkdood exec success in Time: $(date +%F-%T) " >> $LOG_INFO_LOCAL_PATH
        echo "1" > $EXEC_OUT_FILE_PATH
    } 
}

[ ! -d $VRV_MINILINKDOOD_LOCAL_PATH ] && {
    mkdir -p $VRV_MINILINKDOOD_LOCAL_PATH
}

cd $VRV_MINILINKDOOD_LOCAL_PATH
UpdateProj

echo "svn update miniLinkdood project to version: $PROJ_VERSION in Time: $(date +%F-%T)" >> $LOG_INFO_LOCAL_PATH

Compile_MiniLinkdood_Proj
Commit_MiniLinkdood_Exec