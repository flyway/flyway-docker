FROM eclipse-temurin:17-jre-alpine as flyway

RUN apk --no-cache add --update bash openssl
RUN apk --no-cache add --update python3 py3-pip \
    && pip3 install sqlfluff==1.2.1

WORKDIR /flyway

ARG FLYWAY_VERSION
ARG FLYWAY_ARTIFACT_URL=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/

RUN wget ${FLYWAY_ARTIFACT_URL}${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar \
  && chmod -R a+r /flyway \
  && chmod a+x /flyway/flyway

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]

FROM flyway as redgate

RUN apk --no-cache add --update dotnet6-runtime
