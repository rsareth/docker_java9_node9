FROM ubuntu:xenial

COPY serverjre-9.0.4_linux-x64_bin.tar.gz /data/

# From this repo: https://github.com/carlossg/docker-maven
ARG MAVEN_VERSION=3.5.3
ARG USER_HOME_DIR="/root"
ARG SHA=b52956373fab1dd4277926507ab189fb797b3bc51a2a267a193c931fffad8408
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt update && \
      apt install -y curl gnupg ca-certificates xz-utils && \
      mkdir -p /opt && \
      tar xf /data/serverjre-9.0.4_linux-x64_bin.tar.gz -C /opt && \
      rm /data/serverjre-9.0.4_linux-x64_bin.tar.gz && \
      mkdir -p /usr/share/maven /usr/share/maven/ref && \
      curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
      echo "${SHA} /tmp/apache-maven.tar.gz" | sha256sum -c - && \
      tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 && \
      rm -f /tmp/apache-maven.tar.gz && \
      ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV JAVA_HOME /opt/jdk-9.0.4
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# From this repo: https://github.com/nodejs/docker-node/
ENV NODE_VERSION 9.11.1

RUN set -ex \
      && for key in \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        56730D5401028683275BD23C23EFEFE93C4CFFFE \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
      ; do \
        gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
      done \
      && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
      && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
      && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
      && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
      && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
      && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
      && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.5.1

RUN set -ex \
      && for key in \
        6A010C5166006599AA17F08146C2130DFD2497F5 \
      ; do \
        gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
      done \
      && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
      && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
      && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
      && mkdir -p /opt \
      && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
      && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
      && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
      && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

ENV PATH ${JAVA_HOME}/bin:${MAVEN_HOME}/bin:$PATH
