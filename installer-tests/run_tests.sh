#!/usr/bin/env bash

#/ Usage: ./run_tests.sh [-h | --help] [ds | docker-starter <test_command>] [it | installation-test] [at | autoupdate-test]
#/
#/ Standalone commands:
#/     -h, --help               show help text
#/     ds | docker-starter <test_command>
#/                              to run tests script inside of Docker container.
#/                              It will run './run_tests.sh <test_command>', where <test_command> expected to be
#/                              "installation-test" or "autoupdate-test".
#/     it | installation-test   to run installation tests in current environment
#/     at | autoupdate-test     to run autoupdate tests in current environment
#/
#/ Arguments for running tests:
#/     -q, --quiet
#/          to show only information about passed and failed tests.
#/     -t <test_id>, --test-id <test_id>
#/          to run only test with specified <test_id>.
#/          This parameter can't be used with '-tp | --test-id-prefix'.
#/          This parameter can't be used with '-ft | --from-test-id'.
#/     -ft <test_id>, --from-test-id <test_id>
#/          to run tests listed after test with specified <test_id> (including).
#/          This parameter can't be used with '-t | --test-id'.
#/     -tp <test_id_prefix>, --test-id-prefix <test_id_prefix>
#/          to run only tests with specified prefixes.
#/          This parameter can't be used with '-t | --test-id'.
#/
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
SPECIFIED_TEST_NAME='it'


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
  docker run -d -e TESTS_COMMANDS="$SPECIFIED_TEST_NAME" \
                -v "./..:$VUH_SRC_VOLUME" \
                --name "$CONTAINER_NAME" \
                "$IMAGE_NAME" || {
    _show_error_message "Failed to run docker container from image: '$IMAGE_NAME'!"
    exit 1
  }
  _show_updated_message "Waiting for success or error outputs ..."
  while true; do
    container_logs_output="$(docker logs "$CONTAINER_NAME")"
    expecting_success_message='tests successfully finished.'
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

function autoupdate_test() {
  _show_function_title "Running autoupdate test ..."

  _show_updated_message "Creating temporary vuh src analog ..."
  tmp_vuh_src_dir='/opt/old_vuh_simulation'
  mkdir -p "$tmp_vuh_src_dir" || exit 1
  cp -r "$VUH_SRC_VOLUME/." "$tmp_vuh_src_dir" || exit 1

  _show_updated_message "Creating downgraded version of repository ..."
  downgraded_vuh_file="$(sed "s/VUH_VERSION=.*/VUH_VERSION=\'1\.0\.0\'/" "$tmp_vuh_src_dir/vuh.sh")"
  echo "$downgraded_vuh_file" > "$tmp_vuh_src_dir/vuh.sh"

  _show_updated_message "Installing vuh using installer.sh .."
  ".$tmp_vuh_src_dir/installer.sh" -d

  _show_updated_message "Cloning vuh repository ..."
  repo_name='vuh-repo'
  git clone "$VUH_REPO_ADDRESS" "$repo_name"
  cd "$repo_name" || exit 1

  _show_updated_message "Checking vuh installed correctly (downgraded version 1.0.0) ..."
  vuh -v || exit 1

  _show_updated_message "Check autoupdate initialized ..."
  "./../autoupdate.exp" || exit 1

  _show_updated_message "Checking vuh updated correctly (downgraded version 1.0.0) ..."
  vuh -v || exit 1
  [ "$(vuh -v)" != '1.0.0' ] || exit 1

  _show_updated_message "Trying to update vuh manually (when update not required) ..."
  expecting_already_updated='you already have the latest vuh version'
  vuh_update_output="$(vuh --update)" || exit 1
  echo "vuh_update_output: $vuh_update_output"
  if ! [[ $vuh_update_output =~ $expecting_already_updated ]]; then
    _show_error_message "Update command failed!"
    _show_error_message "$vuh_update_output"
    exit 1
  fi

  _show_success_message "Autoupdate tests successfully finished."
}


while [[ $# -gt 0 ]]; do
  case "$1" in
  ds|docker-starter)
    _exit_if_using_multiple_commands "$1"
    COMMAND='docker-starter'
    SPECIFIED_TEST_NAME="$2"
    shift # past value
    shift ;;
  it|installation-test)
    _exit_if_using_multiple_commands "$1"
    COMMAND='installation-test'
    shift ;;
  at|autoupdate-test)
    _exit_if_using_multiple_commands "$1"
    COMMAND='autoupdate-test'
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
autoupdate-test)
  autoupdate_test || exit 1
  exit 0
  ;;
esac
