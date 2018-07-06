FROM ubuntu:18.04

ENV USER nvm
ENV HOME /home/nvm

# Ensure BASH is used for Jenkins pipelines
# TODO: Better way to accomplish this?
RUN rm /bin/sh \
  && ln -s /bin/bash /bin/sh

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV NVM_DIR /usr/local/nvm

ENV NVM $NVM_DIR/nvm.sh

RUN apt update \
  && apt install -y -q --no-install-recommends \
    ca-certificates \
    curl \
    gnupg

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update \
  && apt install -y -q --no-install-recommends yarn

COPY nvm.sh /nvm.sh

RUN useradd -d "${HOME}" "${USER}" \
  && chown -R ${USER} ${NVM_DIR}

USER ${USER}

RUN source $NVM \
  && mkdir -p $NVM_DIR/versions \
  && V=$(nvm ls-remote | tail -n 1) \
  && nvm install ${V} \
  && nvm use ${V}

ENTRYPOINT ["/nvm.sh"]
CMD ["node", "-v"]
