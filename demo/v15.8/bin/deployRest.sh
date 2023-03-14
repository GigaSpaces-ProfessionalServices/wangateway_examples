#!/usr/bin/env bash

################################################################################
# functions used to deploy using the REST Manager
################################################################################
# Where defined, 
# The REST_HOST should include port number
# PASSWORD_FILE should be in a format to be used with --netrc-file 
################################################################################

# upload pu jar file
function upload_processing_unit () {
  REST_HOST="$1"
  PASSWORD_FILE="$2"
  # pu jar path includes path location and name of jar
  PU_JAR_PATH="$3"
  RESOURCE_PATH=$(curl -s -X PUT --header 'Content-Type: multipart/form-data' --header 'Accept: text/plain' --netrc-file $PASSWORD_FILE -F "file=@$PU_JAR_PATH" "http://$REST_HOST/v2/pus/resources")
  echo "$RESOURCE_PATH"
}

# check if pu has been successfully uploaded
function verify_upload () {
  REST_HOST="$1"
  PASSWORD_FILE="$2"
  # pu jar name has only the name of the jar
  PU_JAR_NAME="$3"

  RETRY_COUNT=0
  while [ "$RETRY_COUNT" -lt 3 ]; do
    PU_UPLOAD_COUNT=$(curl  -s  -X GET --header 'Accept: application/json' --netrc-file $PASSWORD_FILE "http://$REST_HOST/v2/pus/resources" | grep -c "$PU_JAR_NAME")
    echo "Checking if pu has been uploaded";
    if [ "$PU_UPLOAD_COUNT" -ne 0 ]; then
      break
    fi
    sleep 20
    RETRY_COUNT=$(($RETRY_COUNT + 1))
  done

  if [ "$PU_UPLOAD_COUNT" -eq 0 ]; then
    echo "false"
  else
    echo "true"
  fi
}

# deploy
function deploy_processing_unit() {
  REST_HOST="$1"
  PASSWORD_FILE="$2"
  JSON_FILE="$3"

  REQUEST_ID=$(curl -s -X POST --header 'Content-Type: application/json' --header 'Accept: text/plain' --netrc-file $PASSWORD_FILE -d @$JSON_FILE "http://$REST_HOST/v2/pus")
  echo "$REQUEST_ID"
}

# undeploy
function undeploy_processing_unit() {
  REST_HOST="$1"
  PASSWORD_FILE="$2"
  PU_NAME="$3"

  # keepFile takes care of cleaning PU resource
  REQUEST_ID=$(curl -s -X DELETE --header 'Accept: text/plain' --netrc-file $PASSWORD_FILE "$REST_HOST/v2/pus/$PU_NAME?keepFile=false")
  echo "$REQUEST_ID"
}

# Check if pu has been successfully deployed
# Returns:
# 'The requested processing unit does not exist'
# Or pu status, for example:
# '"intact"'
# '"broken"'
function check_for_pu_deployment() {
  REST_HOST="$1"
  PASSWORD_FILE="$2"
  PU_NAME="$3"

  #PU_STATUS=$(curl -s -X GET --header 'Accept: application/json' --header 'Accept: text/plain' --netrc-file $PASSWORD_FILE "http://$REST_HOST/v2/pus/$PU_NAME"|grep -Po '"status": *\K"[^"]*"')
  RET_VAL=$(curl -s -X GET --header 'Accept: application/json' --header 'Accept: text/plain' --netrc-file $PASSWORD_FILE "http://$REST_HOST/v2/pus/$PU_NAME")

  if [ "The requested processing unit does not exist" = "$RET_VAL" ]; then
    echo "$RET_VAL"
    return
  fi

  # this grep command returns the matched string using PCRE to capture the group
  # [^"] - character class, any character not matching " (quote)
  PU_STATUS=$(echo "$RET_VAL" | grep -Po '"status": *\K"[^"]*"')
  echo "$PU_STATUS"
}

