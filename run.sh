#!/bin/bash

#set -x

pid=0

CYAN="\033[1;96m"
RED="\033[0;91m"
GREEN="\033[0;92m"
RESET='\033[0m'

print () {
  echo -e "$1 $2 $RESET"
}

info () {
  print "$CYAN" "$1"
}

error() {
  print "$RED" "$1"
}

success() {
  print "$GREEN" "$1"
}

get_connector_my_mc() {
  KEY="$(/usr/local/bin/node /fetch-my-mc-connector.js)"
}

cmd_argument_builder () {
  local args="";
  case "$MODE" in
    "client")
      [[ "$PORT" ]]            && args="$args --port $PORT";
      [[ "$HOST" ]]            && args="$args --host $HOST";
      [[ "$KEY" ]]             && args="$args $KEY";
      [[ "$UDP" = "true" ]]    && args="$args --udp";
      ;;
    "server")
      [[ "$PORT" ]]            && args="$args --live $PORT";
      [[ "$HOST" ]]            && args="$args --host $HOST";
      [[ "$PUBLIC" = "true" ]] && args="$args --public";
      [[ "$FORCE" = "true" ]]  && args="$args --force";
      [[ "$KEY" ]]             && args="$args --key $KEY";
      [[ "$UDP" = "true" ]]    && args="$args --udp";
      ;;
    "filemanager")
      args="--filemanager";
      [[ "$FORCE" = "true" ]]  && args="$args --force";
      [[ "$PUBLIC" = "true" ]] && args="$args --public";
      [[ "$HOST" ]]            && args="$args --host $HOST";
      [[ "$USERNAME" ]]        && args="$args --username $USERNAME";
      [[ "$PASSWORD" ]]        && args="$args --password $PASSWORD";
      [[ "$ROLE" = "admin" ]]  && args="$args --role admin";
      [[ "$ROLE" = "user" ]]   && args="$args --role user";
      [[ "$KEY" ]]             && args="$args --key $KEY";
      [[ "$UDP" = "true" ]]    && args="$args --udp";
      ;;
    "my-mc")
      [[ "$PORT" ]]            && args="$args --port $PORT";
      [[ "$HOST" ]]            && args="$args --host $HOST";
      [[ "$KEY" ]]             && args="$args --connect $KEY";
      [[ "$UDP" = "true" ]]    && args="$args --udp";
      ;;
  esac	

  printf "%s" "$args";
}

# SIGUSR1-handler
my_handler() {
  echo "my_handler"
}

term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}


if ! get_connector_my_mc; then exit 1; fi

ARGS="$(cmd_argument_builder)"

if [[ ! $ARGS ]]; then
  error "Invalid Mode."
  exit 1
fi

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
#trap 'kill ${!}; my_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM SIGINT

# run application
/usr/local/bin/holesail $ARGS &
pid="$!"

# wait forever
while true; do
  tail -f /dev/null & wait ${!}
done
