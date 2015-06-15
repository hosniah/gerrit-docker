#!/bin/bash
set -e
GERRIT_WEBURL=${GERRIT_WEBURL:-$1}
LDAP_SERVER=${LDAP_SERVER:-$2}
LDAP_ACCOUNTBASE=${LDAP_ACCOUNTBASE:-$3}
HTTPD_LISTENURL=${HTTPD_LISTENURL:-http://*:8080}
GERRIT_NAME=${GERRIT_NAME:-gerrit}
GERRIT_VOLUME=${GERRIT_VOLUME:-gerrit-volume}
PG_GERRIT_NAME=${PG_GERRIT_NAME:-pg-gerrit}
GERRIT_IMAGE_NAME=${GERRIT_IMAGE_NAME:-openfrontier/gerrit}
GERRIT_DB=${GERRIT_DB:-reviewdb}
GERRIT_DB_USER=${GERRIT_DB_USER:-gerrit2}
GERRIT_DB_PASS=${GERRIT_DB_PASS:-gerrit}

# Start PostgreSQL.
~/postgres-docker/createPostgres.sh \
${PG_GERRIT_NAME} \
${GERRIT_DB} \
${GERRIT_DB_USER} \
${GERRIT_DB_PASS}

# Create Gerrit volume.
docker run \
--name ${GERRIT_VOLUME} \
${GERRIT_IMAGE_NAME} \
echo "Create Gerrit volume."

# Start Gerrit.
docker run \
--name ${GERRIT_NAME} \
-p 8080:8080 \
-p 29418:29418 \
--volumes-from ${GERRIT_VOLUME} \
-e WEBURL=${GERRIT_WEBURL} \
-e HTTPD_LISTENURL=${HTTPD_LISTENURL} \
-e DATABASE_TYPE=postgresql \
-e DB_PORT_5432_TCP_ADDR=$(docker inspect -f '{{.Node.IP}}' ${PG_GERRIT_NAME}) \
-e DB_PORT_5432_TCP_PORT=5432 \
-e DB_ENV_POSTGRES_DB=${GERRIT_DB} \
-e DB_ENV_POSTGRES_USER=${GERRIT_DB_USER} \
-e DB_ENV_POSTGRES_PASSWORD=${GERRIT_DB_PASS} \
-e AUTH_TYPE=LDAP \
-e LDAP_SERVER=${LDAP_SERVER} \
-e LDAP_ACCOUNTBASE=${LDAP_ACCOUNTBASE} \
-d ${GERRIT_IMAGE_NAME}

