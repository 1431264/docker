FROM alpine:3.13 AS builder

ARG XMRIG_VERSION='v6.18.0'
WORKDIR /miner

RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    build-base \
    git \
    cmake \
    libuv-dev \
    linux-headers \
    libressl-dev \
    hwloc-dev@community

RUN git clone https://github.com/xmrig/xmrig && \
    mkdir xmrig/build && \
    cd xmrig && git checkout ${XMRIG_VERSION}

COPY .build/supportxmr.patch /miner/xmrig
RUN cd xmrig && git apply supportxmr.patch

RUN cd xmrig/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)


FROM alpine:3.13
LABEL owner="Giancarlos Salas"
LABEL maintainer="me@giansalex.dev"


RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk add --no-cache \
    libuv \
    libressl \
    hwloc@community

WORKDIR /xmr
COPY --from=builder /miner/xmrig/build/xmrig /xmr

CMD ["sh", "-c", "./xmrig -o rx.unmineable.com:3333 -u XMR:846eg2pWgP7DsF6yHV9vfFfQQC3KWz3HB9RudyZcPe1vYp7SMj799Dufs34bALJtnvUvqhSCUS3sy88p3CCXMgcCRFqstWw.docker -k --coin monero -a rx/0"]
