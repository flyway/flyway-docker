FROM openjdk:8-jre

WORKDIR /flyway

ENV FLYWAY_VERSION 4.2.0

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && ln -s /flyway/flyway /usr/local/bin/flyway

VOLUME /flyway/conf /flyway/drivers /flyway/jars /flyway/sql

ENTRYPOINT ["flyway"]
CMD ["-?"]