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

# Set environment for directory
KERNEL_DIR=$PWD/kernel
cd $KERNEL_DIR

# Set enviroment for naming kernel
MODEL="Zenfone Max Pro M2"
DEVICE="X01BD"
KERNEL="perf"
CAFTAG="LA.UM.9.12.r1-14800-SMxx50.QSSI12.0 LA.UM.10.2.1.r1-04900-sdm660.0"

# Get defconfig file
DEFCONFIG=asus/X01BD_defconfig

# Get branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)
export BRANCH

# Set environment for etc.
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="z3zens"

# Set environment for telegram
export CHATID="-1001567354257"
export token="5654193670:AAGgu2DWx7tQjGq9tn-uaPIoljdrYWGBWio"
export BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$token/sendDocument"

# Get distro name
DISTRO=$(cat /etc/issue)

# Get all cores of CPU
PROCS=$(nproc --all)
export PROCS

# Check for KernelVer 4.19
ClangMoreStrings="AR=llvm-ar NM=llvm-nm AS=llvm-as STRIP=llvm-strip OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf HOSTAR=llvm-ar HOSTAS=llvm-as LD_LIBRARY_PATH=$TC_DIR/lib LD=ld.lld HOSTLD=ld.lld"
export KBUILD_BUILD_HOST="nrdprjkt"
export LLVM=1
export LLVM_IAS=1

# Check kernel version
KERVER=$(make kernelversion)

# Get last commit
COMMIT_HEAD=$(git log --oneline -1)

# Set Date 
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")

# Set environment for clang
TC_DIR=$KERNEL_DIR/clang
# Get path and compiler string
KBUILD_COMPILER_STRING=$("$TC_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
PATH=$TC_DIR/bin/:$PATH
export LD_LIBRARY_PATH=$TC_DIR/bin/:$LD_LIBRARY_PATH
export PATH KBUILD_COMPILER_STRING

# Set function for telegram
tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}

tg_post_build() {
	# Post MD5 Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	# Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$2"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$3 | <b>MD5 Checksum : </b><code>$MD5CHECK</code>"  
}

# Set function for naming zip file
setversioning() {
    KERNELNAME="[TM]$KERVER-$KERNEL"
    export KERNELNAME
    export ZIPNAME="$KERNELNAME.zip"
}

# Set function for starting compile
build_kernel() {
	echo -e "Kernel compilation starting"

	tg_post_msg "<b>Device : </b><code>$MODEL [$DEVICE]</code>%0A<b>Branch : </b><code>$BRANCH</code>%0A<b>Kernel Version : </b><code>$KERVER</code>%0A<b>CLO Version : </b><code>$CAFTAG</code>%0A<b>Date : </b><code>$(TZ=Asia/Jakarta date)</code>%0A<b>Compiler : </b><code>$KBUILD_COMPILER_STRING</code>%0a<b>Last Commit : </b><code>$COMMIT_HEAD</code>%0A" "$CHATID"

	make O=out $DEFCONFIG

	BUILD_START=$(date +"%s")


	make -j"$PROCS" O=out \
			CC=clang \
			CROSS_COMPILE=aarch64-linux-gnu- \
			HOSTCC=clang \
			HOSTCXX=clang++ ${ClangMoreStrings}


	BUILD_END=$(date +"%s")
	DIFF=$((BUILD_END - BUILD_START))

	if [[ -f "$KERNEL_DIR"/out/arch/arm64/boot/Image.gz-dtb ]]; then
		echo -e "Kernel successfully compiled"
	elif ! [[ -f "$IMG" ]]; then
		echo -e "Kernel compilation failed"
		tg_post_msg "<b>Build failed to compile after $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</b>" "$CHATID" 
		exit 1
	fi
}

# Set function for zipping into a flashable zip
gen_zip() {
	mv "$KERNEL_DIR"/out/arch/arm64/boot/Image.gz-dtb AnyKernel3/Image.gz-dtb
	cd AnyKernel3 || exit
	zip -r9 "$ZIPNAME" * -x .git README.md

	# Prepare a final zip variable
	ZIP_FINAL="$ZIPNAME"

	tg_post_build "$ZIP_FINAL" "$CHATID" "Build took : $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"
	cd ..
}

setversioning
build_kernel
gen_zip
