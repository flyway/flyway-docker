# Azure pipeline agents require specific things in their containers:
# https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#linux-based-containers

FROM node:19-alpine as flyway

ENV LANG C.UTF-8
ENV JAVA_VERSION 17.0.6
ENV JAVA_ALPINE_VERSION 17.0.6_p10-r0

ARG FLYWAY_VERSION
ARG FLYWAY_ARTIFACT_URL=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/

RUN apk add --no-cache --virtual .pipeline-deps readline linux-pam \
  && apk add bash sudo shadow openssl curl tar \
  && apk del .pipeline-deps
RUN apk --no-cache add --update g++ python3 python3-dev py3-pip \
    && pip3 install sqlfluff==1.2.1

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

# Add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-17-openjdk/jre/bin:/usr/lib/jvm/java-17-openjdk/bin

RUN set -x \
	&& apk add --no-cache openjdk17-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

WORKDIR /flyway

RUN curl -L ${FLYWAY_ARTIFACT_URL}${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && chmod -R +r /flyway \
  && chmod +x /flyway/flyway \
  && ln -s /flyway/flyway /usr/local/bin/flyway

FROM flyway as redgate

RUN apk --no-cache add --update icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib \
    && wget https://dot.net/v1/dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh -c 6.0 --runtime dotnet -InstallDir /usr/local/bin \
    && rm ./dotnet-install.sh
