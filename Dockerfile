FROM ubuntu:16.04

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
    && source $NVM_DIR/nvm.sh \
    && mkdir -p /usr/local/nvm/versions/ \
    && nvm install 7 \
    && nvm use 7

RUN echo 'NODE_PATH=$(find $NVM_DIR/versions/v7* -maxdepth 2 -name "node_modules" | tail -n 1)' >> ~/.bashrc \
    && echo 'PATH=$(find $NVM_DIR/versions/v7* -maxdepth 1 -name "bin" | tail -n 1):$PATH' >> ~/.bashrc
