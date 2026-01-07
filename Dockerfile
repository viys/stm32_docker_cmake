FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    sed -i 's|http://archive.ubuntu.com/ubuntu|https://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list; \
    sed -i 's|http://security.ubuntu.com/ubuntu|https://security.ubuntu.com/ubuntu|g' /etc/apt/sources.list; \
    apt-get update -o Acquire::Retries=10 -o Acquire::ForceIPv4=true -o Acquire::https::Timeout=30; \
    apt-get install -y --no-install-recommends \
        cmake build-essential \
        gcc-arm-none-eabi gdb-arm-none-eabi \
        libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib; \
    rm -rf /var/lib/apt/lists/*
