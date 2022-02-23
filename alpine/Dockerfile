FROM eclipse-temurin:11-jre-alpine

RUN apk --no-cache add --update bash openssl

RUN addgroup flyway && adduser -S -h /flyway -D -G flyway flyway
WORKDIR /flyway

USER flyway

ENV FLYWAY_VERSION 8.5.1

RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]
