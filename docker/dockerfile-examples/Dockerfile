FROM ubuntu:xenial

MAINTAINER cascade IPA  <manuelsuarez4444@gmail.com>

RUN apt update \
    && apt -y upgrade \
    && apt install -y build-essential pkg-config autoconf libtool autotools-dev wget nano unzip htop \
       software-properties-common libboost-all-dev libminiupnpc-dev libevent-dev libzmq3-dev \
    && add-apt-repository -y ppa:bitcoin/bitcoin \
    && apt update \
    && apt install -y libdb4.8-dev libdb4.8++-dev

WORKDIR /root

RUN wget -q https://github.com/superdoge-project/superdoge/releases/download/v2.1.1.0/ubuntu-daemon.zip

RUN unzip ubuntu-daemon.zip \
    && rm -f ubuntu-daemon.zip \
    && rm -rf __MACOSX/ \
    && chmod +x superdoge*

EXPOSE 7373

ENTRYPOINT ["./superdoged"]
