#########################################################################
# File Name: 1.sh
# Author: Hello
# mail: Hello@163.com
# Created Time: 2019年11月24日 星期日 22时57分39秒
#########################################################################
#!/bin/bash

NAME=
DIR_LOCAL=$(pwd)
DIR_SRC=$DIR_LOCAL/linux-3.10
DIR_MODULE=$DIR_LOCAL/myModules
DIR_FILE=$DIR_LOCAL/image
COMPILE=/home/lvbing/loongson/mips-loongson-gcc4.9-linux-gnu/bin/mips-linux-gnu-
export PATH=$PATH:$DIR_LOCAL/../mips-loongson-gcc4.9-linux-gnu/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR_LOCAL/../mips-loongson-gcc4.9-linux-gnu/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR_LOCAL/../mips-loongson-gcc4.9-linux-gnu/mips-linux-gnu/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR_LOCAL/../mips-loongson-gcc4.9-linux-gnu/mips-linux-gnu/lib64


cd $DIR_SRC

echo "*****<$COMPILE>****"
echo ------------ Make menu -------------
echo 1: config loongson3_defconfig.
echo 2: Make menuconfig and build kernel
echo 3: Only build kernel image
echo 4: Build the kernel modiules
echo 5: get 'vmlinuz' to file
echo ------------------------------------

if [ ! -d "$DIR_MODULE/" ]; then
	mkdir -p $DIR_MODULE
fi
if [ ! -d "$DIR_FILE/" ]; then
	mkdir -p $DIR_FILE
fi

read -p "Please input you cmd: " INPUT

case $INPUT in
	1)
		make distclean
		cp arch/mips/configs/loongson3_defconfig  .config
		echo "------------end------------"
		;;
	2)
		rm $DIR_SRC/vmlinuz  $DIR_SRC/vmlinux
		make menuconfig ARCH=mips
		make ARCH=mips  CROSS_COMPILE=$COMPILE -j 8
		echo "------------end------------"
		;;
	3)
		rm $DIR_SRC/vmlinuz  $DIR_SRC/vmlinux
		make ARCH=mips  CROSS_COMPILE=$COMPILE -j 8
		echo "------------end------------"
		;;
	4)
		rm -rf $DIR_MODULE/*
		make modules_install INSTALL_MOD_PATH=$DIR_MODULE/ ARCH=mips CROSS_COMPILE=$COMPILE -j 8
		;;
	5)
		sudo rm -rf $DIR_FILE/*
		sudo cp $DIR_SRC/vmlinuz $DIR_FILE/
		sudo cp $DIR_SRC/System.map $DIR_FILE/System.map-3.10.0+
		sudo cp -rf $DIR_MODULE/* $DIR_FILE/
		echo "------------end------------"
		;;
	*)
		echo "cmd error!"
		echo "------------end------------"
		;;
esac

