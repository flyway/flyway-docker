FROM eclipse-temurin:11-jre-alpine

RUN apk --no-cache add --update bash openssl icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib \
    && apk --no-cache add --update libgdiplus --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ \
    && wget https://dot.net/v1/dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh -c 6.0 --runtime dotnet \
    && rm ./dotnet-install.sh

RUN addgroup flyway && adduser -S -h /flyway -D -G flyway flyway
WORKDIR /flyway

USER flyway

ARG FLYWAY_VERSION

RUN wget https://download.red-gate.com/maven/release/org/flywaydb/enterprise/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]
