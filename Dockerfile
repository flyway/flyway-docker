FROM eclipse-temurin:17-jre-focal as flyway

RUN apt-get update \
    && apt-get install -y python3-pip \
    && pip3 install sqlfluff==1.2.1

WORKDIR /flyway

ARG FLYWAY_VERSION
ARG FLYWAY_ARTIFACT_URL=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/

RUN curl -L ${FLYWAY_ARTIFACT_URL}${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz -o flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar \
  && chmod -R a+r /flyway \
  && chmod a+x /flyway/flyway

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]

FROM flyway as redgate

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libc6 libgcc1 libgssapi-krb5-2 libicu66 libssl1.1 libstdc++6 zlib1g