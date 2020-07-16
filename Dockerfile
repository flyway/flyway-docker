FROM adoptopenjdk:11-jre-hotspot

# Add the flyway user and step in the directory
RUN adduser --system --home /flyway --disabled-password --group flyway
WORKDIR /flyway

# Change to the flyway user
USER flyway

ENV FLYWAY_VERSION=6.5.1 \
    FLYWAY_SHA=47ec54975aa1a2e88a2e84b827e5afad9964901d60dec2c0f9f7cefe9dc1a672

RUN curl -L https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && echo "$FLYWAY_SHA  flyway-commandline-6.5.1.tar.gz" | sha256sum -c - \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]
