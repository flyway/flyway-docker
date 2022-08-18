FROM eclipse-temurin:11.0.14.1_1-jre

RUN adduser --system --home /flyway --disabled-password --group flyway
WORKDIR /flyway

USER flyway

ARG FLYWAY_VERSION
ARG FLYWAY_URL=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/

RUN curl -L ${FLYWAY_URL}${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar \
  && chmod -R a+r /flyway \
  && chmod a+x /flyway/flyway

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]
