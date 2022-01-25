FROM bash:5 as fetch
ENV FLYWAY_VERSION 8.4.2
WORKDIR /flyway
RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz

FROM eclipse-temurin:11-alpine

RUN apk --no-cache add --update bash openssl

# Add the flyway user and step in the directory
RUN addgroup flyway \
    && adduser -S -h /flyway -D -G flyway flyway
WORKDIR /flyway

# Change to the flyway user
USER flyway

ENV FLYWAY_VERSION 8.4.2

COPY --from=fetch /flyway/flyway-commandline-${FLYWAY_VERSION}.tar.gz ./

RUN tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && mv flyway-${FLYWAY_VERSION}/* . \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]
