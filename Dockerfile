FROM openjdk:8-jre

# Add the flyway user and step in the directory
RUN adduser -S -h /flyway flyway
WORKDIR /flyway

ENV FLYWAY_VERSION 5.2.4

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && ln -s /flyway/flyway /usr/local/bin/flyway

# Change to the flyway user
USER flyway

ENTRYPOINT ["flyway"]
CMD ["-?"]