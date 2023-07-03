FROM ubuntu:18.04

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget qemu-kvm clang cmake ninja-build pkg-config libgtk-3-dev

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Set up new user
RUN useradd -ms /bin/bash vscode
USER vscode
WORKDIR /home/vscode

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/vscode/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mkdir -p Android/sdk/cmdline-tools
RUN mv cmdline-tools Android/sdk/cmdline-tools/latest
RUN yes | ./Android/sdk/cmdline-tools/latest/bin/sdkmanager --licenses
RUN ./Android/sdk/cmdline-tools/latest/bin/sdkmanager "cmdline-tools;latest" "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"
ENV PATH "$PATH:/home/vscode/Android/sdk/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/vscode/flutter/bin"

# Switch to the Flutter channel you need (optional)
# RUN flutter channel beta
# RUN flutter upgrade

# Accept Android license
RUN yes | flutter doctor --android-licenses

# Run basic check to download Dart SDK
RUN flutter doctor

# Install necessary packages for creating an AVD
RUN ./Android/sdk/cmdline-tools/latest/bin/sdkmanager "system-images;android-29;google_apis;x86_64"

# Create an AVD named 'testAVD'
RUN echo "no" | ./Android/sdk/cmdline-tools/latest/bin/avdmanager create avd --force --name testAVD --abi google_apis/x86_64 --package "system-images;android-29;google_apis;x86_64"

CMD $ANDROID_SDK_ROOT/emulator/emulator -avd testAVD -no-window
