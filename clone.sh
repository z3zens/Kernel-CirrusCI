#! /bin/bash
#
# Script for building Android arm64 Kernel
#
# Copyright (c) 2022 NerdZ3ns <nerd.zensdev@gmail.com>
# Based on Panchajanya1999 script.
#

# Function to show an informational message
msg() {
    echo -e "\e[1;32m$*\e[0m"
}

err() {
    echo -e "\e[1;41m$*\e[0m"
    exit 1
}

# Set function for cloning repository
clone() {
	echo " "
	# Clone AnyKernel3
	git clone --depth=1 https://github.com/nerdprojectorg/AnyKernel3.git -b master AnyKernel3

	# Clone Clang
	git clone --depth=1 https://gitlab.com/RyuujiX/neutron-clang -b Neutron-16 clang
    
        # Clone Kernel
        git clone --depth=1 https://github.com/nerdprojectorg/android_kernel_asus_sdm660 -b tm kernel
}

clone
