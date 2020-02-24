#!/bin/bash
POOL_PATHS="/etc/php5/fpm/pool.d /usr/local/zend/etc/fpm.d /etc/php/*/fpm/pool.d"

FIRST_ELEMENT=1
function json_head {
    printf "{"
    printf "\"data\":["
}

function json_end {
    printf "]"
    printf "}"
}

function check_first_element {
  if [[ $FIRST_ELEMENT -ne 1 ]]; then
    printf ","
  fi
  FIRST_ELEMENT=0
}

function get_pool_config {
  # $1 = pool file
  POOL_FILE="$1"
  POOLNAME=$(grep '\[*\]' ${POOL_FILE} | head -n1 | sed 's/\[//g' | sed 's/\]//g')

  # If the poolname is empty, we don't want it
  if [[ -z ${POOLNAME} ]]; then
    return
  fi

  STATUS_PATH=$(grep 'pm.status_path' ${POOL_FILE} | cut -d'=' -f2 | awk '{$1=$1};1' )
  PING_PATH=$(grep 'ping.path' ${POOL_FILE} | cut -d'=' -f2 | awk '{$1=$1};1' )
  LISTEN=$(grep 'listen' ${POOL_FILE} | grep -v ';' | grep -v "listen\." | cut -d'=' -f2 | tr -d ' ' | sed "s/\$pool/${POOLNAME}/g")

  check_first_element
  printf "{"
  printf "\"{#POOLNAME}\":\"${POOLNAME}\","
  printf "\"{#STATUSPATH}\":\"${STATUS_PATH}\","
  printf "\"{#PINGPATH}\":\"${PING_PATH}\","
  printf "\"{#LISTEN}\":\"${LISTEN}\""
  printf "}"
}

function discover_pools {
  json_head

  for POOL_PATH in ${POOL_PATHS}
  do
    if [[ -d ${POOL_PATH} ]];
      then
        POOL_FILES=$(find ${POOL_PATH} -iname \*.conf)
        for POOL_FILE in ${POOL_FILES}
        do
          get_pool_config ${POOL_FILE}
        done
    fi
  done

  json_end
  exit 0
}

function discover_services {
  json_head

  SERVICES=$(systemctl list-unit-files --type service --state enabled,generated | grep ^php | grep "\-fpm.service" | cut -d'.' -f1-2)

  for SERVICE in ${SERVICES}
  do
    ##
    ## Output of systemdctl is = php7.3-fpm
    ## The service to check however is: php-fpm7.3
    ##
    SERVICE=$(echo ${SERVICE} | cut -d '-' -f1 | sed 's/php/php-fpm/g')

    check_first_element
    printf "{"
    printf "\"{#FPM_SERVICE}\":\"${SERVICE}\""
    printf "}"
  done

  json_end
  exit 0
}

case ${1} in
        services)
                discover_services
                ;;
        pools)
                discover_pools
                ;;
        *)
                #echo "Unsupported discovery ${1}"
                #exit 1
                # 16-01-2020: Temporary fallback to old approach to not break old machines
                discover_pools
                ;;
esac

exit 0
