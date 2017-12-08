FROM openjdk:8-jre-alpine

WORKDIR /flyway

ENV FLYWAY_VERSION 5.0.2

RUN apk --no-cache add openssl \
  && wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && mv flyway-${FLYWAY_VERSION}/* . \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && sed -i 's/bash/sh/' /flyway/flyway \
  && ln -s /flyway/flyway /usr/local/bin/flyway

VOLUME /flyway/conf /flyway/drivers /flyway/jars /flyway/sql

ENTRYPOINT ["flyway"]
CMD ["-?"]