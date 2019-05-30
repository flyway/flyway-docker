FROM openjdk:8-jre-alpine

RUN apk --no-cache add --update bash openssl

# Add the flyway user and step in the directory
RUN adduser -S -h /flyway -D flyway
WORKDIR /flyway

# Change to the flyway user
USER flyway

ENV FLYWAY_VERSION 6.0.0-beta2

RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && mv flyway-${FLYWAY_VERSION}/* . \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz

ENTRYPOINT ["/flyway/flyway"]
CMD ["-?"]