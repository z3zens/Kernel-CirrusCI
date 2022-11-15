#! /bin/bash
#
# Script for building Android arm64 Kernel
#
# Copyright (c) 2022 NerdZ3ns <nerd.zensdev@gmail.com>
# Based on Panchajanya1999 script.
#

AnyKernel3=$PWD/AnyKernel3
mv "$KERNEL_DIR"/out/arch/arm64/boot/Image.gz-dtb $AnyKernel3/Image.gz-dtb
cd $AnyKernel3 || exit
zip -r9 "$ZIPNAME" * -x .git README.md

# Prepare a final zip variable
ZIP_FINAL="$ZIPNAME"

tg_post_build "$ZIP_FINAL" "$CHATID" "Build took : $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"
cd ..
