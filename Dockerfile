FROM openjdk:8-jre

WORKDIR /flyway

ENV FLYWAY_VERSION 5.2.4

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && echo "01d27afad09dd295da4b837be5b67b462085f826  flyway-commandline-${FLYWAY_VERSION}.tar.gz" | sha1sum -c -w \
  && echo "daf6706a1474abffd7098c6f41e6ac15  flyway-commandline-${FLYWAY_VERSION}.tar.gz" | md5sum -c -w \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && ln -s /flyway/flyway /usr/local/bin/flyway

ENTRYPOINT ["flyway"]
CMD ["-?"]
