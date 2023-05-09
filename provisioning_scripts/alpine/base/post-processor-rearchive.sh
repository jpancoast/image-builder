#!/bin/sh

cd $OUTPUT_DIRECTORY
gunzip rootfs.tar.gz
tar -xf rootfs.tar
cd rootfs
tar -cf $BUILD_NAME.tar *
gzip $BUILD_NAME.tar
mv $BUILD_NAME.tar.gz $IMAGE_DIRECTORY
