FROM ubuntu:18.04

ENV WORKING_USER nvm

ENV USERID 1000
ENV USERGID 1000
ENV WORKING_GROUP nvm

# Ensure BASH is used for Jenkins pipelines
# TODO: Better way to accomplish this?
RUN rm /bin/sh \
  && ln -s /bin/bash /bin/sh

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

ENV NVM_DIR /usr/local/nvm

ENV NVM $NVM_DIR/nvm.sh
ENV APP_DIR "/app"

# Packages to
# * Acquire dependencies
ENV ACQUIRE_DEPENDENCIES "apt-transport-https ca-certificates curl gnupg"
# * Clone repositories
ENV CLONE_REPOSITORIES "git openssh-client"
# * Scripting dependencies
ENV SCRIPTING_DEPENDENCIES "jq"

RUN apt update \
  && apt install -y -q --no-install-recommends \
    ${ACQUIRE_DEPENDENCIES} \
    ${CLONE_REPOSITORIES} \
    ${SCRIPTING_DEPENDENCIES}

RUN mkdir -p "${NVM_DIR}" \
  && groupadd -g ${USERGID} "${WORKING_GROUP}" \
  && useradd -u ${USERID} -g "${WORKING_GROUP}" -d "${NVM_DIR}" "${WORKING_USER}" \
  && mkdir -p ${APP_DIR} \
  && chown -R ${WORKING_USER} ${NVM_DIR} ${APP_DIR} \
  && chmod -R u+rw ${NVM_DIR} ${APP_DIR}

USER ${WORKING_USER}

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

USER root

ENTRYPOINT ["/nvm.sh"]
CMD ["node", "-v"]
