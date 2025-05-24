#!/usr/bin/env bash

#/ This is script for testing vuh installation and auto updates mechanisms.

APP_NAME='run_tests.sh'

VUH_REPO_ADDRESS='https://github.com/Greewil/version-update-helper.git'

IMAGE_NAME='vuh-installation-test-image'
CONTAINER_NAME='vuh-installation-test'
VUH_SRC_VOLUME='/opt/src'

# shellcheck disable=SC2034
STARTING_DIR="$(pwd)"

# Output colors
NEUTRAL_COLOR='\e[0m'
RED='\e[1;31m'        # for errors
# shellcheck disable=SC2034
YELLOW='\e[1;33m'     # for warnings
# shellcheck disable=SC2034
BROWN='\e[0;33m'      # for inputs
LIGHT_CYAN='\e[1;36m' # for changes
GREEN='\e[1;32m'      # for success

# Console input variables (Please don't modify!)
COMMAND='docker-start'
# -- Arguments:
# -- Specified params:


function _show_function_title() {
  printf '\n'
  echo "$1"
}

function _show_info_message() {
  message=$1
  [ "$ARGUMENT_QUIET" = 'false' ] && echo "$message"
}

function _show_error_message() {
  message=$1
  echo -en "$RED($APP_NAME : ERROR) $message$NEUTRAL_COLOR\n"
}

function _show_updated_message() {
  message=$1
  echo -en "$LIGHT_CYAN($APP_NAME : CHANGED) $message$NEUTRAL_COLOR\n"
}

function _show_success_message() {
  message=$1
  echo -en "$GREEN($APP_NAME : SUCCESS) $message$NEUTRAL_COLOR\n"
}

function _show_invalid_usage_error_message() {
  message=$1
  _show_error_message "$message"
  _show_info_message 'Use "vuh --help" to see available commands and options information'
}

function _exit_if_using_multiple_commands() {
  last_command=$1
  if [ "$COMMAND" != 'docker-start' ]; then
    _show_invalid_usage_error_message "You can't use both commands: '$COMMAND' and '$last_command'!"
    exit 1
  fi
}

function _show_cant_use_both_arguments() {
  arg1_name=$1
  arg2_name=$2
  checking_arg_value=$3
  checking_arg_default_value=$4
  if [ "$checking_arg_value" != "$checking_arg_default_value" ]; then
    _show_invalid_usage_error_message "You can't use both parameters: '$arg1_name' and '$arg2_name'!"
    exit 1
  fi
}

function docker_starter() {
  _show_function_title "Starting tests in docker ..."
  _show_updated_message "Building image ..."
  docker build . -t "$IMAGE_NAME" || {
    _show_error_message "Failed to run 'docker build .'!"
    exit 1
  }
  _show_updated_message "Removing old images ..."
  docker ps -q -f name="$CONTAINER_NAME" | xargs -r docker stop
  docker ps -a -q -f name="$CONTAINER_NAME" | xargs -r docker rm
  _show_updated_message "Running tests ..."
  docker run -d -v "./..:$VUH_SRC_VOLUME" --name "$CONTAINER_NAME" "$IMAGE_NAME" || {
    _show_error_message "Failed to run docker container from image: '$IMAGE_NAME'!"
    exit 1
  }
  _show_updated_message "Waiting for success or error outputs ..."
  while true; do
    container_logs_output="$(docker logs "$CONTAINER_NAME")"
    expecting_success_message='Installation tests successfully finished.'
    expecting_error_message='ERROR'
    container_exit_code="$(docker inspect "$CONTAINER_NAME" --format='{{.State.ExitCode}}')"
    if [ "$container_exit_code" = '0' ] && [[ $container_logs_output =~ $expecting_success_message ]]; then
      echo "$container_logs_output"
      _show_success_message "Container with tests successfully finished"
      exit 0
    elif [ "$container_exit_code" != '0' ] || [[ $container_logs_output =~ $expecting_error_message ]]; then
      echo "$container_logs_output"
      _show_error_message "Tests failed"
      exit 1
    fi
    sleep 2
  done
}

function installation_test() {
  _show_function_title "Running installation test ..."

  _show_updated_message "Installing vuh using installer.sh .."
  ".$VUH_SRC_VOLUME/installer.sh" -d

  _show_updated_message "Cloning vuh repository ..."
  repo_name='vuh-repo'
  git clone "$VUH_REPO_ADDRESS" "$repo_name"
  cd "$repo_name" || exit 1

  _show_updated_message "Trying to use 'vuh lv -q' ..."
  vuh lv -q || exit 1
  [ "$(vuh lv -q)" = "$(./vuh.sh lv -q)" ] || exit 1

  _show_updated_message "Checking full 'vuh lv' output have no warnings ..."
  warning_text='(vuh : WARNING)'
  vuh_full_output="$(vuh lv)" || exit 1
  if [[ $vuh_full_output =~ $warning_text ]]; then
    _show_error_message "Full output of 'vuh lv' shouldn't have any warnings!"
    _show_error_message "$vuh_full_output"
    exit 1
  fi
  _show_success_message "Installation tests successfully finished."
}


while [[ $# -gt 0 ]]; do
  case "$1" in
  ds|docker-starter)
    _exit_if_using_multiple_commands "$1"
    COMMAND='docker-starter'
    shift ;;
  it|installation-test)
    _exit_if_using_multiple_commands "$1"
    COMMAND='installation-test'
    shift ;;
  -h|--help)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--help'
    shift ;;
  -*)
    _show_invalid_usage_error_message "Unknown option '$1'!"
    exit 1 ;;
  *)
    _show_invalid_usage_error_message "Unknown command '$1'!"
    exit 1 ;;
  esac
done

function show_help() {
  grep '^#/' <"$0" | cut -c4-
}


case "$COMMAND" in
--help)
  show_help
  exit 0
  ;;
docker-starter)
  docker_starter || exit 1
  exit 0
  ;;
installation-test)
  installation_test || exit 1
  exit 0
  ;;
esac
