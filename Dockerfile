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

RUN curl -L https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb
RUN apt-get update \
    && apt-get install -y apt-transport-https \
    && apt-get update \
    && apt-get install -y dotnet-runtime-6.0
