#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
#######################################################################################
#######################################################################################
#
# Collab Tools Proxy - Bot Cert
#
#######################################################################################
#######################################################################################
#
# Collab Tools Proxy - Bot Cert
#
# Created: 07/02/2024
# Author: togofish
#
# Description
# Stages the bot cert for the Collab Tools Proxy. Does the following:
# 1. Creates a directory for the certs - /usr/local/openresty/nginx/conf/ssl
# 2. Copies the client.crt and client.key to the directory
# 3. Changes the permissions on the key to 44 and the crt to 444
#
# Notes
# - Only tested on Red Hat Enterprise Linux 8
# - The client.crt and client.key must be in the media directory
#
#######################################################################################
# Deployment Properties
#######################################################################################
#
#######################################################################################
# Exit Codes
#######################################################################################
#
# 12 - client.crt not found
# 13 - client.key not found
#
#######################################################################################
logTag="collabtools-proxy-bot-cert"
#######################################################################################
# main function
#######################################################################################
function main {
  logInfo "Checking for certificates"
  if [ ! -f "${ASSET_DIR}/media/client.crt" ]; then
    logErr "client.crt not found in ${ASSET_DIR}/media"
    exit 12
  fi
  if [ ! -f "${ASSET_DIR}/media/client.key" ]; then
    logErr "client.key not found in ${ASSET_DIR}/media"
    exit 13
  fi
  logInfo "Setting up certificates"
  mkdir -p /usr/local/openresty/nginx/conf/ssl
  cp "${ASSET_DIR}/media/client.crt" /usr/local/openresty/nginx/conf/ssl
  cp "${ASSET_DIR}/media/client.key" /usr/local/openresty/nginx/conf/ssl
  chmod 400 /usr/local/openresty/nginx/conf/ssl/client.key
  chmod 444 /usr/local/openresty/nginx/conf/ssl/client.crt
}
#######################################################################################
# helpers
#######################################################################################
logDir="/opt/cons3rt-agent/log"
logFile="${logDir}/${logTag}-$(date "+%Y%m%d-%H%M%S").log"
# Set up the log file
mkdir -p ${logDir}
chmod 700 ${logDir}
touch "${logFile}"
chmod 644 "${logFile}"
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" 2>&1 | tee -a "${logFile}"; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" 2>&1 | tee -a "${logFile}"; }
# gets any custom properties defined at launch
if [ -z "${DEPLOYMENT_HOME:-}" ]; then
  DEPLOYMENT_PROPERTIES="$(ls /opt/cons3rt-agent/run/Deployment*/deployment-properties.sh)"
else
  DEPLOYMENT_PROPERTIES="${DEPLOYMENT_HOME}/deployment-properties.sh"
fi
# saves CONS3RT_ROLE_NAME to deployment-properties.sh if set
if [ -n "${CONS3RT_ROLE_NAME:-}" ] && ! grep -q CONS3RT_ROLE_NAME "${DEPLOYMENT_PROPERTIES}"; then
  logInfo "Adding CONS3RT_ROLE_NAME='${CONS3RT_ROLE_NAME}' to ${DEPLOYMENT_PROPERTIES}"
  echo "CONS3RT_ROLE_NAME='${CONS3RT_ROLE_NAME}'" | tee -a "${DEPLOYMENT_PROPERTIES}" >/dev/null
fi
logInfo "DEPLOYMENT_PROPERTIES = ${DEPLOYMENT_PROPERTIES}"
# shellcheck disable=SC1090
source "${DEPLOYMENT_PROPERTIES}"
# gets ASSET_DIR if not set
if [ -z "${ASSET_DIR:-}" ]; then
  ASSET_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/..
fi
logInfo "ASSET_DIR = ${ASSET_DIR}"
#######################################################################################
# run
#######################################################################################
main
result=$?
logInfo "Exiting with code ${result} ..."
exit ${result}
