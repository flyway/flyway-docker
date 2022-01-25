FROM bash:5 as fetch
ENV FLYWAY_VERSION 8.4.2
WORKDIR /flyway
RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz
