FROM ubuntu:18.04

ENV USER nvm

# Ensure BASH is used for Jenkins pipelines
# TODO: Better way to accomplish this?
RUN rm /bin/sh \
  && ln -s /bin/bash /bin/sh

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV NVM_DIR /usr/local/nvm

ENV NVM $NVM_DIR/nvm.sh

RUN apt update \
  && apt install -y -q --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq

RUN mkdir -p "${NVM_DIR}" \
  && groupadd -g 999 "docker" \
  && groupadd -g 1000 "sambashare" \
  && useradd -g 999 -G "sambashare" -d "${NVM_DIR}" "${USER}" \
  && chown -R ${USER} ${NVM_DIR} \
  && chmod -R u+rw ${NVM_DIR}

USER ${USER}

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash

RUN source $NVM \
  && mkdir -p $NVM_DIR/versions \
  && V=$(nvm ls-remote | tail -n 1) \
  && nvm install ${V} \
  && nvm use ${V}

RUN . ${NVM} \
  && V=$(nvm ls | tail -n 1) \
  && nvm use ${V} \
  && npm install -g yarn \
  && yarn --version

COPY nvm.sh /nvm.sh

ENTRYPOINT ["/nvm.sh"]
CMD ["node", "-v"]
