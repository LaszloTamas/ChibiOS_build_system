#!/bin/bash

TOOLCHAIN_WEB=https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q2-update/+download/gcc-arm-none-eabi-4_7-2013q2-20130614-linux.tar.bz2
TOOLCHAIN_SRC=gcc-arm-none-eabi-4_7-2013q2-20130614-linux.tar.bz2
CHIBIOS_WEB=http://github.com/ChibiOS-Upstream/ChibiOS-RT.git
CONFIG_FILE_NAME=build.conf

BUILD_SYSTEM_PATH=$(readlink -e $0 | xargs dirname)
cd $BUILD_SYSTEM_PATH
cd ..
PROJECT_PATH=`pwd`

# usage #######################################################
usage ()
{
    echo -e "
    usage: $0 <option-1>
    option(s):
    \tconfigure : Configure the build system
    \tinstall : install toolchain and chibiOS
    \tcreate : create new project\n"
}

# Create new project ###########################################
create_new_project ()
{
    echo "Add project name:"
    read PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]
    then
	echo "Error: Invalid project name!"
	exit 1
    fi

    PROJECT_NAME="`echo $PROJECT_NAME | sed -e "s/ /_/g"`"

    if [ -d $PROJECT_PATH/projects/${PROJECT_NAME} ]
	then
	    echo "This project name is exist."
	    exit 1
    fi

    mkdir -p $PROJECT_PATH/projects/${PROJECT_NAME}

    cp $BUILD_SYSTEM_PATH/templates/chconf.h $PROJECT_PATH/projects/$PROJECT_NAME/chconf.h
    cp $BUILD_SYSTEM_PATH/templates/main.c $PROJECT_PATH/projects/$PROJECT_NAME/main.c
    cp $BUILD_SYSTEM_PATH/templates/halconf.h $PROJECT_PATH/projects/$PROJECT_NAME/halconf.h
    cp $BUILD_SYSTEM_PATH/templates/mcuconf.h $PROJECT_PATH/projects/$PROJECT_NAME/mcuconf.h

    cat $BUILD_SYSTEM_PATH/templates/template.cbp | sed -e "s/PROJECT_NAME/${PROJECT_NAME}/g"  > $PROJECT_PATH/projects/$PROJECT_NAME/$PROJECT_NAME.cbp
    cat $BUILD_SYSTEM_PATH/templates/Makefile | sed -e "s/PROJECT_NAME/${PROJECT_NAME}/g" > $PROJECT_PATH/projects/$PROJECT_NAME/Makefile

    echo -e "\nCreate project done."
}

# Configure the build system ##################################
configure_build_system ()
{
	# create symbol link ###################################
	if [ ! -x "$PROJECT_PATH/build.sh" ]
	    then
		ln -s $BUILD_SYSTEM_PATH/build.sh $PROJECT_PATH/build.sh
	fi

	# build.conf
	if [ -s "$PROJECT_PATH/$CONFIG_FILE_NAME" ]
	    then
		echo "This file already exist!"
	    else
		echo -e  "#########################################"	>> $CONFIG_FILE_NAME
		echo -e  "Build system config file for ChibiOS" 	>> $CONFIG_FILE_NAME
		echo -e  "########################################\n" 	>> $CONFIG_FILE_NAME
		echo -e  "# download ChibiOS" 				>> $CONFIG_FILE_NAME
		echo -e  "CHIBIOS = y\n"				>> $CONFIG_FILE_NAME
		echo -e  "# automatic update for chibiOS"		>> $CONFIG_FILE_NAME
		echo -e  "UPDATE_CHIBI = n\n" 				>> $CONFIG_FILE_NAME
		echo -e  "# download toolchain" 			>> $CONFIG_FILE_NAME
		echo -e  "TOOLCHAIN = n\n" 				>> $CONFIG_FILE_NAME
		echo -e  "# install toolchain" 				>> $CONFIG_FILE_NAME
		echo -e  "TOOLCHAIN_INSTALL = n\n" 			>> $CONFIG_FILE_NAME
		echo -e  "# download ST-UTIL" 				>> $CONFIG_FILE_NAME
		echo -e  "ST_UTIL = n\n"				>> $CONFIG_FILE_NAME
		echo -e  "# default board template"			>> $CONFIG_FILE_NAME
		echo -e  "TEMPLATE = ST_STM32F4_DISCOVERY\n"		>> $CONFIG_FILE_NAME
	fi

}

# Install build system ########################################
install_build_system ()
{
	echo "Install the build system."
	# check user ###########################################
	if [ `whoami` != "root" ]
	    then
		echo "Please login as root!"
		#exit 1
	fi

	# Configure toolchain ###################################
	if [ -s "$PROJECT_PATH/$TOOLCHAIN_SRC" ]
	    then
		echo "Toolchain already downloaded!"
	    else
		wget $TOOLCHAIN_WEB
	fi
	#tar -xvjf gcc-arm-none-eabi-4_7-2013q2-20130614-linux.tar.bz2 -C /opt
	#tar -xvjf $TOOLCHAIN_SRC

	# Configure ChibiOS ####################################
	if [ -d "$PROJECT_PATH/ChibiOS" ]
	    then
		echo "ChibiOS already downloaded!"
	    else
		git clone $CHIBIOS_WEB ./ChibiOS
	fi

	echo "Install done."
}

#################################################################
# main ##########################################################
#################################################################
case $1 in
    "configure")
	configure_build_system
	;;
    "install")
	install_build_system
	;;
    "create")
	create_new_project
	;;
    *)
	usage
	;;
esac

exit 0

