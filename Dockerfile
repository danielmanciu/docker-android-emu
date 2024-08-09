# Use the official Ubuntu 22.04 image as the base image
FROM ubuntu:22.04

# Expose the ADB port
EXPOSE 5555

# Set environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk

# Install necessary packages
RUN apt-get update && \
    apt-get install -y wget unzip openjdk-17-jdk && \
    apt-get clean

# Download and install the Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT} && \
    cd ${ANDROID_SDK_ROOT} && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mkdir latest && \
    mv cmdline-tools/* latest && \
    mv latest cmdline-tools

# Set environment variables for Android SDK
ENV PATH=$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator

# Accept licenses
RUN yes | sdkmanager --licenses

# Install Android Emulator and system images
RUN sdkmanager "platform-tools" "emulator" "system-images;android-33;default;x86_64" "platforms;android-33"

# Create an AVD (Android Virtual Device)
RUN echo "no" | avdmanager create avd -n android13 -k "system-images;android-33;default;x86_64"

COPY test /opt/test

WORKDIR /opt/test

RUN ./gradlew build

ENTRYPOINT ["/bin/bash", "-c", "emulator -avd android13 -no-window -no-audio & ( adb wait-for-device && ./gradlew connectedAndroidTest && cp -r app/build/reports/androidTests /opt/reports )"]

# CMD [ "./gradlew connectedAndroidTest && cp -r app/build/reports/androidTests /opt/reports" ]
