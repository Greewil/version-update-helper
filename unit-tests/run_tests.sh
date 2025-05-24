#!/usr/bin/env bash

#/ Usage: ./run_tests.sh [-h | --help] [<args>]
#/
#/ Standalone commands:
#/     -h, --help               show help text
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
#/ This is script for testing vuh.

APP_NAME='run_tests.sh'

VUH_REPO_ADDRESS='https://github.com/Greewil/version-update-helper.git'

TRIMMED_HEADER='test_id,branch_name,correct_result,asserting_error,use_separate_env,command'
ASSERT_DATA_FILE='assert_data.csv'
TEXT_FOR_COMMA_REPLACEMENT='{{comma}}'
TEXT_FOR_VUH_REPLACEMENT='{{vuh}}'

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
COMMAND='run-tests'
# -- Arguments:
ARGUMENT_QUIET='false'
ARGUMENT_TEST_ID='false'
ARGUMENT_STARTING_FROM_TEST_ID='false'
ARGUMENT_TEST_ID_PREFIX='false'
# -- Specified params:
SPECIFIED_TEST_ID=''
SPECIFIED_STARTING_FROM_TEST_ID=''
SPECIFIED_TEST_ID_PREFIX=''


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

function _run_test() {
  test_id=$1
  branch_name=$2
  correct_result=$3
  asserting_error=$4
  command=$5
  repo_name=$6
  cd "$repo_name" || return 1
  git checkout "test_fixture_$branch_name" || return 1
  eval_command="${command//$TEXT_FOR_COMMA_REPLACEMENT/,}" || return 1
  eval_command="${eval_command//$TEXT_FOR_VUH_REPLACEMENT/\"$STARTING_DIR/../vuh.sh\"}" || return 1
  if [ "$asserting_error" = 'yes' ]; then
    vuh_output="$(eval "$eval_command" 2>&1)"
    if ! [[ $vuh_output =~ $correct_result ]]; then
      _show_error_message "Incorrect vuh error output!"
      _show_error_message "Expected text in error output: '$correct_result'"
      _show_error_message "Obtained error: '$vuh_output'"
      exit 1
    fi
  else
    vuh_output="$(eval "$eval_command")" || {
      _show_error_message 'vuh throw an error during execution!'
      eval "\"$STARTING_DIR/../vuh.sh\" $eval_command"
      return 1
    }
    vuh_output=$(echo "$vuh_output" | awk '{$1=$1};1') || exit 1
    if [ "$vuh_output" != "$correct_result" ]; then
      _show_error_message "Incorrect vuh output!"
      _show_error_message "Expected output: '$correct_result'"
      _show_error_message "Obtained output: '$vuh_output'"
      exit 1
    fi
  fi
  cd - || return 1
}

function _run_test_in_tmp_environment() {
  test_id=$1
  branch_name=$2
  correct_result=$3
  asserting_error=$4
  command=$5
  test_dir_name=$6
  _show_updated_message "Running test '$test_id' (using branch test_fixture_$branch_name) ..."
  if [ "$test_dir_name" = '' ]; then
    unique_test_dir="$test_id-$(date +%s%N)"
  else
    unique_test_dir="$test_dir_name"
  fi
  cd "$STARTING_DIR" || exit 1
  mkdir -p "tmp/$unique_test_dir"
  cd "tmp/$unique_test_dir" || exit 1
  repo_name='vuh-repo'
  git clone "$VUH_REPO_ADDRESS" "$repo_name"
  _run_test "$test_id" "$branch_name" "$correct_result" "$asserting_error" "$command" "$repo_name" || exit 1
  cd "$STARTING_DIR" || exit 1
  _show_success_message "Test '$test_id' successfully finished"
}


function run_tests() {
  test_dir="all-tests-$(date +%s%N)"
  start_point_passed='false'
  tests_passed=0
  if [ "$ARGUMENT_STARTING_FROM_TEST_ID" = 'false' ]; then
    start_point_passed='true'
  fi
  while IFS="" read -r line || [ -n "$line" ]
  do
    line_without_comments=${line%%\#*}
    trimmed_line="$(echo "$line_without_comments" | tr -d '[:space:]')" || exit 1
    # check line not empty and its not a header line
    if [ "$trimmed_line" != '' ] && [ "$trimmed_line" != "$TRIMMED_HEADER" ]; then
      _show_info_message "handling line: $line_without_comments"
      incorrect_line='false'

      # checking line hase same columns as table header
      separator=','
      line_without_separators="${line_without_comments//$separator}"
      separators_in_line=$(((${#line_without_comments} - ${#line_without_separators}) / ${#separator}))
      header_without_separators="${TRIMMED_HEADER//$separator}"
      separators_in_header=$(((${#TRIMMED_HEADER} - ${#header_without_separators}) / ${#separator}))
      [ "$separators_in_header" != "$separators_in_line" ] && incorrect_line='true'

      # parsing params
      test_id=$(echo "$line_without_comments" | cut -d',' -f1) || incorrect_line='true'
      test_id=$(echo "$test_id" | awk '{$1=$1};1') || exit 1
      branch_name=$(echo "$line_without_comments" | cut -d',' -f2) || incorrect_line='true'
      branch_name=$(echo "$branch_name" | awk '{$1=$1};1') || exit 1
      correct_result=$(echo "$line_without_comments" | cut -d',' -f3) || incorrect_line='true'
      correct_result=$(echo "$correct_result" | awk '{$1=$1};1') || exit 1
      asserting_error=$(echo "$line_without_comments" | cut -d',' -f4) || incorrect_line='true'
      asserting_error=$(echo "$asserting_error" | awk '{$1=$1};1') || exit 1
      use_separate_env=$(echo "$line_without_comments" | cut -d',' -f5) || incorrect_line='true'
      use_separate_env=$(echo "$use_separate_env" | awk '{$1=$1};1') || exit 1
      command=$(echo "$line_without_comments" | cut -d',' -f6) || incorrect_line='true'
      command=$(echo "$command" | awk '{$1=$1};1') || exit 1
      if [ "$incorrect_line" = 'true' ]; then
        _show_error_message 'Incorrect format in line:'
        _show_error_message "'$line'"
        return 1
      fi

      # selecting tmp dir for test
      current_test_dir=''
      if [ "$use_separate_env" = 'no' ]; then
        current_test_dir="$test_dir"
      fi

      # handling starting filters
      if [ "$ARGUMENT_STARTING_FROM_TEST_ID" = 'true' ] && [ "$test_id" = "$SPECIFIED_STARTING_FROM_TEST_ID" ]; then
        start_point_passed='true'
      fi
      is_test_planned_to_start='false'
      if [ "$start_point_passed" = 'true' ]; then
        if [ "$ARGUMENT_TEST_ID" = 'true' ]; then
          if [ "$test_id" = "$SPECIFIED_TEST_ID" ]; then
            is_test_planned_to_start='true'
          fi
        elif [ "$ARGUMENT_TEST_ID_PREFIX" = 'true' ]; then
          if [[ $test_id =~ ^$SPECIFIED_TEST_ID_PREFIX ]]; then
            is_test_planned_to_start='true'
          fi
        else
          is_test_planned_to_start='true'
        fi
      fi

      # starting test
      if [ "$is_test_planned_to_start" = 'true' ]; then
        echo ""
        _run_test_in_tmp_environment "$test_id" "$branch_name" "$correct_result" "$asserting_error" "$command" "$current_test_dir"
        tests_passed=$((tests_passed+1))
      else
        _show_info_message "test $test_id skipped"
      fi
    fi
  done < "$ASSERT_DATA_FILE"
  if [ "$ARGUMENT_TEST_ID" = 'true' ]; then
    if [ "$tests_passed" = 0 ]; then
      _show_error_message "Test $SPECIFIED_TEST_ID not found"
    fi
    if [ "$tests_passed" = 1 ]; then
      _show_success_message "Test $SPECIFIED_TEST_ID successfully finished"
    fi
  else
    _show_success_message "All tests ($tests_passed) successfully finished"
  fi
}


while [[ $# -gt 0 ]]; do
  case "$1" in
  -h|--help)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--help'
    shift ;;
  -q|--quiet)
    ARGUMENT_QUIET='true'
    shift ;;
  -t|--test-id)
    _show_cant_use_both_arguments '-t | --test-id' '-ft | --from-test-id' "$ARGUMENT_STARTING_FROM_TEST_ID" 'false'
    _show_cant_use_both_arguments '-t | --test-id' '-tp | --test-id-prefix' "$ARGUMENT_TEST_ID_PREFIX" 'false'
    ARGUMENT_TEST_ID='true'
    SPECIFIED_TEST_ID="$2"
    shift # past value
    shift ;;
  -ft|--from-test-id)
    _show_cant_use_both_arguments '-ft | --from-test-id' '-t | --test-id' "$ARGUMENT_TEST_ID" 'false'
    ARGUMENT_STARTING_FROM_TEST_ID='true'
    SPECIFIED_STARTING_FROM_TEST_ID="$2"
    shift # past value
    shift ;;
  -tp|--test-id-prefix)
    _show_cant_use_both_arguments '-tp | --test-id-prefix' '-t | --test-id' "$ARGUMENT_TEST_ID" 'false'
    ARGUMENT_TEST_ID_PREFIX='true'
    SPECIFIED_TEST_ID_PREFIX="$2"
    shift # past value
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
run-tests)
  run_tests || exit 1
  exit 0
  ;;
esac
