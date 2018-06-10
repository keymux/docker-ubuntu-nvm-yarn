FROM ubuntu:18.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV NVM_DIR /usr/local/nvm

ENV NVM $NVM_DIR/nvm.sh

RUN apt update && apt install -y -q --no-install-recommends \
    ca-certificates \
    curl \
    gnupg

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash \
    && source $NVM \
    && mkdir -p $NVM_DIR/versions \
    && nvm install $(nvm ls-remote | tail -n 1)

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update && apt install -y -q --no-install-recommends yarn
