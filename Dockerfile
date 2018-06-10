FROM ubuntu:18.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt update && apt install -y -q --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    git \
    libssl-dev \
    python \
    rsync \
    software-properties-common \
    wget

ENV NVM_DIR /usr/local/nvm

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh
