#########################################################################
# File Name: go.sh
# Author: Hello
# mail: Hello@163.com
# Created Time: 2019年10月28日 星期一 22时26分28秒
#########################################################################
#!/bin/bash

#IF_LOG_ALL=y
DIR_ROOT=
BRANCH=1.22                                    # if v1.22 modify ./crosstool-ng/kconfig/zconf.hash.c +167
SAMPLES=aarch64-rpi3-linux-gnu
TARGET_VENDOR=rpi3
NAME_TOOL_TARGET=
NAME_TOOL_ALIAS=
# Os options
IF_KERNEL_linux=y
IF_LINUX_CUSTOM=
NAME_KERNEL=


# -------------------------------------------------
# sudo apt-get install gperf flex bison texinfo gawk libtool automake libncurses5-dev g++ help2man
install_package(){
	sudo apt-get install help2man
}
# -------------------------------------------------
# download : crosstool-ng
# https://github.com/crosstool-ng/crosstool-ng.git
download_ct_ng(){
cd $DIR_ROOT
if [ -d crosstool-ng ] ;then
	read -n 2 -p "You had src. So now checkout to $BRANCH ? [y/n] >> " rep
	echo
	if [ $rep == 'y' ] ;then
		cd $DIR_PROJECT
		git checkout -b crosstool.local.$BRANCH  remotes/origin/$BRANCH
	else
		exit
	fi
else
	git clone https://github.com/crosstool-ng/crosstool-ng.git
fi
}
# -------------------------------------------------
compile_install(){
if [ -d $DIR_PREFIX ] ;then
	rm -rf $DIR_PREFIX
else
	mkdir -p $DIR_PREFIX
fi
	cd $DIR_PROJECT
# run the bootstrap script before running configure:
	./bootstrap
# config crosstool
	./configure --prefix=$DIR_PREFIX
# compile
	make
# install crosstool
	make install
# please export enverment
	echo "you must do next before use ct-ng:"
	echo "export PATH=\$PATH:$DIR_PREFIX/bin"
}
# -------------------------------------------------
menuconfig_ct_ng(){
	cd $DIR_PROJECT
	read -n 2 -p "if read config base '$SAMPLES', and cover current? [y/n] >> " rep
	echo
	if [ $rep == 'y' ] ;then
		cp $DIR_PROJECT/samples/$SAMPLES/crosstool.config  $DIR_PROJECT/.config
		if [ -n "$NAME_TOOL_TARGET" ]; then
			echo CT_TARGET=\"$NAME_TOOL_TARGET\"  >> $DIR_PROJECT/.config
		fi
		if [ -n "$NAME_TOOL_ALIAS" ]; then
			echo CT_TARGET_ALIAS=\"$NAME_TOOL_ALIAS\" >>  $DIR_PROJECT/.config
		fi
		echo CT_PREFIX_DIR=\"$DIR_TOOL_PREFIX\"   >> $DIR_PROJECT/.config
		echo CT_TARGET_VENDOR=\"$TARGET_VENDOR\" >> $DIR_PROJECT/.config
		echo CT_LOCAL_TARBALLS_DIR=\"$DIR_TARBALLS\" >> $DIR_PROJECT/.config
		if [ -n "$IF_LOG_ALL" ]; then
			echo CT_LOG_ALL=$IF_LOG_ALL >> $DIR_PROJECT/.config
		fi
		# os set
		if [ -n "$IF_KERNEL_linux" ]; then
			echo CT_KERNEL_linux=$IF_KERNEL_linux >> $DIR_PROJECT/.config
			if [ -n "$IF_LINUX_CUSTOM" ]; then
				echo CT_KERNEL_LINUX_CUSTOM=$IF_LINUX_CUSTOM >> $DIR_PROJECT/.config
				if [ -n "$DIR_LINUX_CUSTOM" ]; then
					echo CT_KERNEL_LINUX_CUSTOM_LOCATION=\"$DIR_LINUX_CUSTOM\" >> $DIR_PROJECT/.config
				fi
			fi
		fi
		echo -----------------------------------------
		cat $DIR_PROJECT/.config
		echo -----------------------------------------
	fi
	read -n 2 -p "if menuconfig ? [y/n] >> " rep
	echo
	if [ $rep == 'y' ] ;then
	./ct-ng menuconfig
	fi
}
# -------------------------------------------------
build_ct_ng(){
echo -------------
#export LD_LIBRARY_PATH=/usr/local/gmp-5.0.1/lib:/usr/local/mpfr-4.0.2/lib/:/usr/local/mpc-1.0.1:$LD_LIBRARY_PATH
#echo $LD_LIBRARY_PATHL
echo -------------

cd $DIR_ROOT
if [ -d $DIR_TOOL_PREFIX ] ;then
	rm -rf $DIR_TOOL_PREFIX
fi
mkdir -p $DIR_TOOL_PREFIX
if [ ! -d $DIR_TARBALLS ] ;then
	mkdir -p $DIR_TARBALLS
fi

	cd $DIR_PROJECT
	 # --with-gmp=/usr/local/gmp-5.0.1 --with-mpfr=/usr/local/mpfr-3.1.0 --with-mpc=/usr/local/mpc-0.9
	./ct-ng build
}
# -------------------------------------------------




if [ ! -n "$DIR_ROOT" ] ;then
	DIR_ROOT=$(pwd)
fi

cd $DIR_ROOT
if [ -d crosstool-ng ] ;then
	echo
else
	read -n 2 -p "Not find src. So now download ct-ng? [y/n] >> " rep
	echo
	if [ $rep == 'y' ] ;then
		download_ct_ng
	else
		exit
	fi
fi

DIR_PREFIX=$DIR_ROOT/ct_prefix
DIR_PROJECT=$DIR_ROOT/crosstool-ng
DIR_TARBALLS=$DIR_ROOT/tarballs
DIR_TOOL_PREFIX=$DIR_ROOT/tool_prefix
DIR_LINUX_CUSTOM=$DIR_ROOT/kernel/$NAME_KERNEL

echo ------------------------------------------------
echo "project dir= $DIR_PROJECT"
echo "prefix  dir= $DIR_PREFIX"
echo "samples    = $SAMPLES"
echo "branch     = $BRANCH"
echo ------------------------------------------------
echo 1, install Depend on the package of ct-ng.
echo 2, download ct-ng and change the branches.
echo 3, compile and install ct-ng.
echo 4, ct-ng menuconfig, config gcc tool.
echo 5, ct-ng build, creat gcc tool.
echo ------------------------------------------------
echo -n "Enter you cmd:"
read cmd

case $cmd in
	1)	echo “you select [$cmd]”
		install_package
		;;
	2)	echo “you select [$cmd]”
		download_ct_ng
		;;
	3)  echo “you select [$cmd]”
		compile_install
		;;
	4)  echo “you select [$cmd]”
		menuconfig_ct_ng
		;;
	5)  echo “you select [$cmd]”
		build_ct_ng
		;;
	*)  echo “you select error!”
		exit
		;;
esac
