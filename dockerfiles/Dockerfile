FROM eclipse-temurin:17-jre-jammy as flyway

WORKDIR /flyway

ARG FLYWAY_VERSION

COPY flyway-commandline-${FLYWAY_VERSION}.tar.gz .

RUN gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar \
  && chmod -R a+r /flyway \
  && chmod a+x /flyway/flyway

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]

FROM flyway as redgate

ENV REDGATE_DOCKER=true

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && apt-get install -y --no-install-recommends libc6 libgcc1 libgcc-s1 libgssapi-krb5-2 libicu70 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g \
    && pip3 install sqlfluff==3.0.7
    