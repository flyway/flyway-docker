FROM eclipse-temurin:11.0.14.1_1-jre

RUN apt-get update &&  apt-get install -y openssh-server

RUN adduser --system --home /flyway --disabled-password --group flyway
WORKDIR /flyway

USER flyway

ARG FLYWAY_VERSION="9.1.6"

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar \
  && chmod -R a+r /flyway \
  && chmod a+x /flyway/flyway


ENV PATH="/flyway:${PATH}"

ENV FLYWAY_EDITION=community
ENV BASTION_SSH_KEY=""
ENV DB_HOST=""
ENV BASTION_USERNAME=""
ENV BASTION_HOST=""

COPY tunnel.sh /flyway/tunnel.sh
