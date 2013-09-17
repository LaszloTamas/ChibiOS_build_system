#!/bin/bash

TOOLCHAIN_WEB=https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q2-update/+download/gcc-arm-none-eabi-4_7-2013q2-20130614-linux.tar.bz2
TOOLCHAIN_SRC=gcc-arm-none-eabi-4_7-2013q2-20130614-linux.tar.bz2
CHIBIOS_WEB=http://github.com/ChibiOS-Upstream/ChibiOS-RT.git

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


    echo -e "
Choose project template:
ST_STM32F4_DISCOVERY\t[1]
ST_STM32L_DISCOVERY\t[2]"

    read PROJECT_TEMPLATE

    if [ -z "$PROJECT_TEMPLATE" ]
    then
	PROJECT_TEMPLATE="1"
    fi

    case $PROJECT_TEMPLATE in
	1) PROJECT_TEMPLATE_DIR="ST_STM32F4_DISCOVERY" ;;
	2) PROJECT_TEMPLATE_DIR="ST_STM32L_DISCOVERY"  ;;
	*) echo "INVALID NUMBER!"
	    exit 1 ;;
    esac

    mkdir -p $PROJECT_PATH/projects/${PROJECT_NAME}

    cp $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/chconf.h $PROJECT_PATH/projects/$PROJECT_NAME/chconf.h
    cp $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/main.c $PROJECT_PATH/projects/$PROJECT_NAME/main.c
    cp $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/halconf.h $PROJECT_PATH/projects/$PROJECT_NAME/halconf.h
    cp $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/mcuconf.h $PROJECT_PATH/projects/$PROJECT_NAME/mcuconf.h
    cp $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/board.c $PROJECT_PATH/projects/$PROJECT_NAME/board.c
    cp $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/board.h $PROJECT_PATH/projects/$PROJECT_NAME/board.h

    cat $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/template.cbp | sed -e "s/PROJECT_NAME/${PROJECT_NAME}/g"  > $PROJECT_PATH/projects/$PROJECT_NAME/$PROJECT_NAME.cbp
    cat $BUILD_SYSTEM_PATH/templates/$PROJECT_TEMPLATE_DIR/Makefile | sed -e "s/PROJECT_NAME/${PROJECT_NAME}/g" > $PROJECT_PATH/projects/$PROJECT_NAME/Makefile

    echo -e "\nCreate project done."
}

# Install build system ########################################
install_build_system ()
{
	# create symbol link ###################################
	if [ ! -x "$PROJECT_PATH/build.sh" ]
	    then
		ln -s $BUILD_SYSTEM_PATH/build.sh $PROJECT_PATH/build.sh
	fi

	echo "Download ChibiOS [Y/n]?"
	read CH

	if [ -z "$CH" ]
	then
		CH="Y"
	fi

	echo "Install toolchain [Y/n]?"
	read TC

	if [ -z "$TC" ]
	then
		TC="Y"
	fi

	if [[ $TC == "Y" || $TC == "y" ]]
	then
	    if [ `whoami` != "root" ]
	    then
		echo "Please login as root!"
		exit 1
	    fi
	fi

	# Configure ChibiOS ####################################
	if [[ $CH == "Y" || $CH == "y" ]]
	then
	    if [ -d "$PROJECT_PATH/ChibiOS" ]
	    then
		echo "ChibiOS already downloaded!"
	    else
		git clone $CHIBIOS_WEB ./ChibiOS
	    fi
	fi

	# Configure toolchain ###################################
	if [[ $TC == "Y" || $TC == "y" ]]
	then
	    if [ `arm-none-eabi-gcc --version &> /dev/null && echo "OK" || echo "FAIL"` == "OK" ]
	    then
		echo "Toolchain works!"
	    else
		if [ -s "$PROJECT_PATH/$TOOLCHAIN_SRC" ]
		then
		    echo "Toolchain already downloaded!"
		else
		    wget $TOOLCHAIN_WEB
		fi

		tar -xvjf $TOOLCHAIN_SRC -C /opt
		cd /opt/gcc*/bin
		for f in *; do ln -s /opt/gcc-arm-none*/bin/$f /usr/bin/$f ;done
	    fi
	fi

	echo "Install done!"
}

#################################################################
# main ##########################################################
#################################################################
case $1 in
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

