FROM node:10-alpine

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8
# openjdk
ENV JAVA_VERSION 8u242
ENV JAVA_ALPINE_VERSION 8.242.08-r0
# flyway
ENV FLYWAY_VERSION 6.2.3
ENV SNOWFLAKE_DRIVER_VERSION 3.12.0

# Requirement for the non glibc-based containers
# https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#non-glibc-based-containers
RUN apk add --no-cache --virtual .pipeline-deps readline linux-pam \
  && apk add bash sudo shadow openssl curl tar\
  && apk del .pipeline-deps

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

# Install openjdk-8
# add a simple script that can auto-detect the appropriate JAVA_HOME value
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
	&& apk add --no-cache \
		openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# Azure pipeline creates vsts_azpcontainer with uid 1001
# If you create a user with -u, the default value is 1001 and it will cause an error at the "Initialize containers" of azure pipeline.
# Add the flyway user and step in the directory
# RUN addgroup -S flyway \
#   && adduser -S -h /flyway -u 1101 -G flyway -D flyway
WORKDIR /flyway

# Change to the flyway user
# USER flyway

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  # make the flyway executable by other users
  && chmod +x /flyway/flyway \
  && ln -s /flyway/flyway /usr/local/bin/flyway \
  # download snowflake jdbc driver
  && rm drivers/snowflake-jdbc-*.jar \
  && curl -o drivers/snowflake-jdbc-${SNOWFLAKE_DRIVER_VERSION}.jar \
     https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/${SNOWFLAKE_DRIVER_VERSION}/snowflake-jdbc-${SNOWFLAKE_DRIVER_VERSION}.jar

# Do not define ENTRYPOINT
# https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#linux-based-containers
# ENTRYPOINT ["/flyway/flyway"]
# CMD ["-?"]