FROM node:10-alpine

# This file builds images which are suitable for use in Azure Pipeline agent jobs; these require more elements
# to be present than the minimal Flyway commandline container.

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Define the version of OpenJDK we want
ENV JAVA_VERSION 8u275
ENV JAVA_ALPINE_VERSION 8.275.01-r0

ENV FLYWAY_VERSION 8.5.9

# This is a requirement for non glibc-based containers
# see https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#non-glibc-based-containers
RUN apk add --no-cache --virtual .pipeline-deps readline linux-pam \
  && apk add bash sudo shadow openssl curl tar\
  && apk del .pipeline-deps

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

# Install openjdk-8
# Add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

RUN set -x \
	&& apk add --no-cache openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

WORKDIR /flyway

# This is a requirement to securely manage software installation; it will be cleaned up before the OCI container image build completes.
RUN apk add --no-cache --virtual .build-deps \
    gnupg

# Fetch and import public key into GPG keyring
# https://www.spinics.net/lists/trinity-devel/msg01400.html
RUN gpg --keyserver hkp://pgp.mit.edu:11371 \ 
--recv-keys F79157DB93697AA32CD4C46CC485C5A843FADB15

RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  # Download the GPG detached signature for the tarball.
  && wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz.asc \
  # Download the checksum for the tarball.
  && wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz.sha1 \
  # Use GPG to verify that the tarball was signed by the owner of the key obtained.
  && gpg --verify flyway-commandline-${FLYWAY_VERSION}.tar.gz.asc flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  #	Test that the stated checksum matches the tarball checksum by using the sha1sum tool.
  && echo "$(cat flyway-commandline-${FLYWAY_VERSION}.tar.gz.sha1)  flyway-commandline-${FLYWAY_VERSION}.tar.gz"  | sha1sum -c - \
  # If software package verification succeeds, install flyway-commandline
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && chmod +x /flyway/flyway \
  && ln -s /flyway/flyway /usr/local/bin/flyway

# Do not define ENTRYPOINT. This is important for Azure pipeline agent jobs.
# https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#linux-based-containers
