#!/usr/bin/env bash

#/ Usage: ./run_tests.sh [-h | --help] [arguments]
#/
#/ Standalone commands:
#/     -h, --help               show help text
#/
#/ Arguments for running tests:
#/     -t <test_name>, --test-name <test_name>
#/          to run only test with specified <test_name>.
#/
#/ This is script for testing vuh installation and auto updates mechanisms.

APP_NAME='run_tests.sh'

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
COMMAND='run-all-tests'
# -- Arguments:
# -- Specified params:
SPECIFIED_TEST_NAME=''


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
  _show_info_message 'Use "./run_tests.sh --help" to see available commands and options information'
}

function _exit_if_using_multiple_commands() {
  last_command=$1
  if [ "$COMMAND" != 'docker-start' ]; then
    _show_invalid_usage_error_message "You can't use both commands: '$COMMAND' and '$last_command'!"
    exit 1
  fi
}

function run_all_tests() {
  echo "TODO"
}

function run_specified_test() {
  echo "TODO"
}


while [[ $# -gt 0 ]]; do
  case "$1" in
  -t|--test-name)
    COMMAND='run-specified-test'
    SPECIFIED_TEST_NAME="$2"
    shift # past value
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
run-specified-test)
  run_specified_test || exit 1
  exit 0
  ;;
run-all-tests)
  run_all_tests || exit 1
  exit 0
  ;;
esac
