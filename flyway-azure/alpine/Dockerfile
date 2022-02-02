FROM node:10-alpine

# This file builds images which are suitable for use in Azure Pipeline agent jobs; these require more elements
# to be present than the minimal Flyway commandline container.

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Define the version of OpenJDK we want
ENV JAVA_VERSION 8u275
ENV JAVA_ALPINE_VERSION 8.275.01-r0

ENV FLYWAY_VERSION 8.4.4

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

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && chmod +x /flyway/flyway \
  && ln -s /flyway/flyway /usr/local/bin/flyway

# Do not define ENTRYPOINT. This is important for Azure pipeline agent jobs.
# https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#linux-based-containers
