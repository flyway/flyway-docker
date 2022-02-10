FROM eclipse-temurin:11-jre-windowsservercore
WORKDIR /flyway

ENV FLYWAY_VERSION=8.4.4

RUN curl -Uri https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$($env:FLYWAY_VERSION)/flyway-commandline-$($env:FLYWAY_VERSION).tar.gz -OutFile flyway-commandline-$($env:FLYWAY_VERSION).tar.gz
RUN tar -xzf flyway-commandline-$($env:FLYWAY_VERSION).tar.gz --strip-components=1
RUN rm flyway-commandline-$($env:FLYWAY_VERSION).tar.gz

ENV PATH="C:\flyway;$($env.PATH)"

ENTRYPOINT ["flyway.cmd"]
CMD ["-?"]
