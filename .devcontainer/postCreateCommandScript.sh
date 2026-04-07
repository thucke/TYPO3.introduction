#!/bin/bash
set -eu

# post start script
echo "BEGIN: postCreateCommandScript.sh"

if [[ ${DB_SERVER_TYPE} =~ (mysql|mariadb) ]]; then
  export TYPO3_INSTALL_DB_DRIVER="mysqli"
  export TYPO3_INSTALL_DB_DBNAME="${MYSQLI_DBNAME}"
elif [ "${DB_SERVER_TYPE}" == "sqlite" ]; then
  export TYPO3_INSTALL_DB_DRIVER="pdo_sqlite"
  export TYPO3_INSTALL_DB_DBNAME="${SQLITE_DBFILE_PATH}"
fi

# check if docker containers are already running only if docker cli is installed
if [ -n `which docker` ] && [ "${DB_SERVER_TYPE:-sqlite}" != "sqlite" ]; then
  echo "postCreateCommandScript: Checking if docker containers are already running"
  if [ `docker compose ls -q --filter "name=^${COMPOSE_PROJECT_NAME}$" | wc -l` -eq 0 ]; then
    compose_filename="${WORKSPACE_ROOT}/.devcontainer/docker/docker-compose.backend.yaml"
    export COMPOSE_PROFILES+=", ${DB_SERVER_TYPE}"
    # start docker containers for initialization
    echo "postCreateCommandScript: Starting docker containers for ${COMPOSE_PROJECT_NAME} with database server type ${DB_SERVER_TYPE}"
    docker compose -f ${compose_filename} up -d --wait || [ $? -eq 1 ] && echo "Maybe something went wrong starting docker containers. Please check docker ps output and logs for ${COMPOSE_PROJECT_NAME}."
  else
    echo "Docker containers for ${COMPOSE_PROJECT_NAME} are already running."
  fi
fi

# ignite TYPO3 environment for the first time
echo "postCreateCommandScript: Ignite TYPO3 environment for the first time"
${WORKSPACE_ROOT}/.devcontainer/docker/igniteEnvironment.sh

echo "END: postCreateCommandScript.sh"
