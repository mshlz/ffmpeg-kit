#!/bin/bash

# to clear shit
# sudo rm -rf __prebuilt-*

# copy the bin from __prebuilt-****/android-arm64/ffmpeg/bin
# chown $USER ffmpeg
# chmod 500 ffmpeg

# -----------------------------
name=make_android_ffmpeg

docker build -t $name . &&
docker run -v $PWD/__prebuilt-$(date +%s):/var/app/prebuilt/ $name bash -c "ANDROID_NDK_ROOT=/.ndk/android-ndk-r22b ./android.sh -d --enable-android-media-codec --enable-android-zlib --enable-gpl --enable-x265 --enable-x264 --disable-x86-64 --disable-x86 --disable-arm-v7a --disable-arm-v7a-neon" 