FROM eclipse-temurin:11-jre

RUN adduser --system --home /flyway --disabled-password --group flyway
WORKDIR /flyway

# This is a requirement to securely manage software installation; it will be cleaned up before the OCI container image build completes.
RUN apt-get update && apt-get install --no-install-recommends --yes gnupg2

USER flyway

ENV FLYWAY_VERSION 8.5.9

# Fetch and import public key into GPG keyring
# https://www.spinics.net/lists/trinity-devel/msg01400.html
RUN gpg --keyserver hkp://pgp.mit.edu:11371 \ 
--recv-keys F79157DB93697AA32CD4C46CC485C5A843FADB15

RUN curl -SLO https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  # Download the GPG detached signature for the tarball.
  && curl -SLO https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz.asc \
  # Download the checksum for the tarball.
  && curl -SLO https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz.sha1 \
  # Use GPG to verify that the tarball was signed by the owner of the key obtained.
  && gpg --verify flyway-commandline-${FLYWAY_VERSION}.tar.gz.asc flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  #	Test that the stated checksum matches the tarball checksum by using the sha1sum tool.
  && echo "$(cat flyway-commandline-${FLYWAY_VERSION}.tar.gz.sha1)  flyway-commandline-${FLYWAY_VERSION}.tar.gz"  | sha1sum -c - \
  # If software package verification succeeds, install flyway-commandline
  && gzip -d flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xf flyway-commandline-${FLYWAY_VERSION}.tar --strip-components=1 \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar

USER root  
# Remove virtual package
RUN apt-get remove --yes gnupg2

USER flyway

ENV PATH="/flyway:${PATH}"

ENTRYPOINT ["flyway"]
CMD ["-?"]
