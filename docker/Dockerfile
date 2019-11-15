FROM openjdk:8-alpine

# set some defaults

COPY share/lingk-fission-cli-0.0.1-SNAPSHOT.jar /tmp/lingk-fission-cli.jar
COPY install.sh /opt/install.sh
RUN /opt/install.sh

CMD bash
