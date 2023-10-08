FROM ubuntu:22.04 as base

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install -y vim cmake curl wget htop git unzip zip autoconf automake libtool pkg-config curl \
    git doxygen nasm cmake gcc gperf texinfo yasm bison autogen wget autopoint meson ninja-build ragel \
    groff gtk-doc-tools libtasn1-bin
# https://stackoverflow.com/a/49848507
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV BASH_ENV ~/.bashrc

# install java & setup JAVA_HOME
RUN curl -s https://get.sdkman.io | bash
RUN source ~/.sdkman/bin/sdkman-init.sh && sdk install java 17.0.8.1-tem 
ENV JAVA_HOME /root/.sdkman/candidates/java/17.0.8.1-tem


FROM base

# install android tools
ENV SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip" \
    ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_SDK_ROOT="/usr/local/android-sdk" \
    ANDROID_VERSION=34 \
    ANDROID_BUILD_TOOLS_VERSION=34.0.0 

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip > /dev/null \
    && rm sdk.zip \
    && mkdir cmdline-tools/latest \
    && mv cmdline-tools/{bin,lib,source.properties} cmdline-tools/latest \
    && mkdir "$ANDROID_HOME/licenses" || true \
    && echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$ANDROID_HOME/licenses/android-sdk-license"

# accept all licenses (for some reason this shit return non-zero code so || true override this)
RUN yes y | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses || true

# IDK what this do
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --uninstall "cmake;3.10.2.4988404" "cmake;3.18.1"

# Install Android Build Tool and Libraries
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --update
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"

# install Android NDK
# versions from ffmpeg-kit CI: 'r22b-linux-x86_64', 'r23b-linux', 'r24-linux', 'r25b-linux'
ENV NDK_VERSION_TO_DOWNLOAD r22b-linux-x86_64
RUN curl "https://dl.google.com/android/repository/android-ndk-${NDK_VERSION_TO_DOWNLOAD}.zip" -o ndk.zip && \
    unzip -q -o ndk.zip -d .ndk
RUN echo "export ANDROID_NDK_ROOT=/.ndk/$(ls .ndk)" >> ~/.bashrc

WORKDIR /var/app
COPY . .



# to compile:
# ./android.sh -d --enable-android-media-codec --enable-android-zlib --disable-arm-v7a
# ./android.sh -d --enable-android-media-codec --enable-android-zlib --disable-x86-64 --disable-x86


