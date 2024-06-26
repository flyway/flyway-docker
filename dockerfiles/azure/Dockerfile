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

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

WORKDIR /flyway

COPY flyway-commandline-${FLYWAY_VERSION}-linux-alpine-x64.tar.gz .

RUN tar -xzf flyway-commandline-${FLYWAY_VERSION}-linux-alpine-x64.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}-linux-alpine-x64.tar.gz \
  && chmod -R +r /flyway \
  && chmod +x /flyway/flyway \
  && ln -s /flyway/flyway /usr/local/bin/flyway

FROM flyway as redgate

ENV REDGATE_DOCKER=true

RUN apk add --no-cache icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib icu \
  && apk --no-cache add --update g++ python3 python3-dev py3-pip \
  && pip3 install sqlfluff==1.2.1
