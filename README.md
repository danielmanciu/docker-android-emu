## Docker Android Emulator image

Repo for personal tests.

Docker image that installs and runs an Android 13 Vanilla emulator. Currently starts instrumented tests from a test app.

Build with:
```console
$ docker build -t android_emu
```

Run:
```console
$ docker run --device=/dev/kvm -d -v ./reports:/opt/reports android_emu
```