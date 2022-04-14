FROM eclipse-temurin:11-jre-windowsservercore
WORKDIR /flyway

ARG FLYWAY_VERSION

RUN curl -Uri https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$($env:FLYWAY_VERSION)/flyway-commandline-$($env:FLYWAY_VERSION)-windows-x64.zip -OutFile flyway-commandline-$($env:FLYWAY_VERSION)-windows-x64.zip
RUN tar -xf flyway-commandline-$($env:FLYWAY_VERSION)-windows-x64.zip --strip-components=1
RUN rm flyway-commandline-$($env:FLYWAY_VERSION)-windows-x64.zip
RUN rm -r jre

ENV PATH="C:\flyway;$($env.PATH)"

ENTRYPOINT ["flyway.cmd"]
CMD ["-?"]
