FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    cmake \
    build-essential \
    gcc-arm-none-eabi \
    gdb-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib
