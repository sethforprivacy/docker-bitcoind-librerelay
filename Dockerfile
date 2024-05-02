# Base for this image pulled from https://github.com/sethforprivacy/docker-bitcoind,
# originally based on https://github.com/kylemanna/docker-bitcoind

# Use the latest available Ubuntu image as build stage
FROM ubuntu:latest as builder

# Upgrade all packages and install dependencies
RUN apt-get update \
    && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        git \
        build-essential \
        libtool \
        autotools-dev \
        automake \
        pkg-config \
        bsdmainutils \
        python3 \
        libevent-dev \
        libboost-dev \
        libzmq3-dev \
        libsqlite3-dev \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set variables necessary for download and verification of bitcoind
ARG BRANCH=libre-relay-v27.0
ARG COMMIT_HASH=a4c23998d7776a39970725071b8f745b4e55de49
ARG NPROC

# Switch to Bitcoin source directory
WORKDIR /bitcoin

# Build bitcoind LibreRelay from source
# Flags pulled from https://github.com/jamesob/docker-bitcoind/blob/master/bin/build-docker-bitcoin
# and https://github.com/lncm/docker-bitcoind/blob/master/26.0/Dockerfile
RUN set -ex && git clone --recursive --branch ${BRANCH} \
    --depth 1 --shallow-submodules \
    https://github.com/petertodd/bitcoin . \
    && test `git rev-parse HEAD` = ${COMMIT_HASH} || exit 1 \
    && ./autogen.sh \
    && ./configure CXXFLAGS="-O2" \
    --prefix="/opt/bitcoin" \
    --disable-man \
    --disable-shared \
    --disable-ccache \
    --disable-tests \
    --enable-static \
    --enable-reduce-exports \
    --without-gui \
    --without-libs \
    --with-utils \
    --with-sqlite=yes \
    --with-daemon \
    --disable-bench \
    --disable-gui-tests \
    --disable-fuzz-binary \
    --disable-maintainer-mode \
    --disable-dependency-tracking \
    && make -j${NPROC:-$(nproc)} \
    && make install

# Use latest Ubuntu image as base for main image
FROM ubuntu:latest
LABEL author="Kyle Manna <kyle@kylemanna.com>" \
      maintainer="Seth For Privacy <seth@sethforprivacy.com>"

WORKDIR /bitcoin

# Set bitcoin user and group with static IDs
ARG GROUP_ID=1000
ARG USER_ID=1000
RUN userdel ubuntu \
    && groupadd -g ${GROUP_ID} bitcoin \
    && useradd -u ${USER_ID} -g bitcoin -d /bitcoin bitcoin

# Copy over bitcoind binaries
COPY --chown=bitcoin:bitcoin --from=builder /opt/bitcoin/bin/bitcoin* /usr/local/bin/

# Upgrade all packages and install dependencies
RUN apt-get update \
    && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gosu \
    libevent-dev \
    libzmq3-dev \
    libsqlite3-dev \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy scripts to Docker image
COPY ./bin ./docker-entrypoint.sh /usr/local/bin/

# Enable entrypoint script
ENTRYPOINT ["docker-entrypoint.sh"]

# Set HOME
ENV HOME /bitcoin

# Expose default p2p and RPC ports
EXPOSE 8332 8333

# Expose default bitcoind storage location
VOLUME ["/bitcoin/.bitcoin"]

CMD ["btc_oneshot"]
