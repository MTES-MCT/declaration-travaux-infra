FROM jboss/keycloak:7.0.0
LABEL maintainer="tristan.robert.44@gmail.com"
ARG FRANCE_CONNECT_VERSION=1.2
RUN curl -L https://github.com/InseeFr/Keycloak-FranceConnect/releases/download/${FRANCE_CONNECT_VERSION}/keycloak-franceconnect-${FRANCE_CONNECT_VERSION}.jar --output /opt/jboss/keycloak/standalone/deployments/keycloak-franceconnect-${FRANCE_CONNECT_VERSION}.jar