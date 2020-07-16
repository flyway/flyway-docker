FROM openjdk:8-jre-alpine

RUN apk --no-cache add --update bash openssl

# Add the flyway user and step in the directory
RUN adduser -S -h /flyway -D flyway
WORKDIR /flyway

# Change to the flyway user
USER flyway

ENV FLYWAY_VERSION=6.5.1 \
    FLYWAY_SHA=47ec54975aa1a2e88a2e84b827e5afad9964901d60dec2c0f9f7cefe9dc1a672

RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && echo "$FLYWAY_SHA  flyway-commandline-6.5.1.tar.gz" | sha256sum -c - \
  && mv flyway-${FLYWAY_VERSION}/* . \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz

ENTRYPOINT ["/flyway/flyway"]
CMD ["-?"]
