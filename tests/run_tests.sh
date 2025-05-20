#!/usr/bin/env bash

#/ script for testing vuh

APP_NAME='run_tests.sh'

TRIMMED_HEADER='test_id,branch_name,correct_result,command'
ASSERT_DATA_FILE='assert_data.csv'

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


function _show_function_title() {
  printf '\n'
  echo "$1"
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

function _run_test() {
  test_id=$1
  branch_name=$2
  correct_result=$3
  command=$4
  repo_name=$5
  cd "$repo_name" || return 1
  git checkout "test_fixture_$branch_name" || return 1
  # shellcheck disable=SC2086
  vuh_output="$(vuh $command)" || {
    _show_error_message 'vuh throw an error during execution!'
    vuh $command
    return 1
  }
  if [ "$vuh_output" != "$correct_result" ]; then
    _show_error_message "Incorrect vuh output!"
    _show_error_message "Expected output: '$correct_result'"
    _show_error_message "Obtained output: '$vuh_output'"
    exit 1
  fi
  cd - || return 1
}

function _run_test_in_tmp_environment() {
  test_id=$1
  branch_name=$2
  correct_result=$3
  command=$4
  test_dir=$5
  _show_updated_message "Running test '$test_id' (using branch test_fixture_$branch_name) ..."
  if [ "$test_dir" = '' ]; then
    test_dir="$test_id-$(date +%s%N)"
  fi
  cd "$STARTING_DIR" || exit 1
  mkdir -p "tmp/$test_dir"
  cd "tmp/$test_dir" || exit 1
  repo_name='vuh-repo'
  git clone 'git@github.com:Greewil/version-update-helper.git' "$repo_name"
  _run_test "$test_id" "$branch_name" "$correct_result" "$command" "$repo_name" || exit 1
  cd "$STARTING_DIR" || exit 1
  _show_success_message "Test '$test_id' successfully finished"
}


function run_all_tests() {
  test_dir="all-tests-$(date +%s%N)"
  while IFS="" read -r line || [ -n "$line" ]
  do
    line_without_comments=${line%%\#*}
    trimmed_line="$(echo "$line_without_comments" | tr -d '[:space:]')" || exit 1
    # check line not empty and its not a header line
    if [ "$trimmed_line" != '' ] && [ "$trimmed_line" != "$TRIMMED_HEADER" ]; then
      echo "Line without comments: $line_without_comments"
      incorrect_line='false'
      separator=','
      line_without_separators="${line_without_comments//$separator}"
      separators_in_line=$(((${#line_without_comments} - ${#line_without_separators}) / ${#separator}))
      header_without_separators="${TRIMMED_HEADER//$separator}"
      separators_in_header=$(((${#TRIMMED_HEADER} - ${#header_without_separators}) / ${#separator}))
      [ "$separators_in_header" != "$separators_in_line" ] && incorrect_line='true'
      test_id=$(echo "$line_without_comments" | cut -d',' -f1) || incorrect_line='true'
      test_id=$(echo "$test_id" | awk '{$1=$1};1') || exit 1
      branch_name=$(echo "$line_without_comments" | cut -d',' -f2) || incorrect_line='true'
      branch_name=$(echo "$branch_name" | awk '{$1=$1};1') || exit 1
      correct_result=$(echo "$line_without_comments" | cut -d',' -f3) || incorrect_line='true'
      correct_result=$(echo "$correct_result" | awk '{$1=$1};1') || exit 1
      command=$(echo "$line_without_comments" | cut -d',' -f4) || incorrect_line='true'
      command=$(echo "$command" | awk '{$1=$1};1') || exit 1
      if [ "$incorrect_line" = 'true' ]; then
        _show_error_message 'Incorrect format in line:'
        _show_error_message "'$line'"
        return 1
      fi
      _run_test_in_tmp_environment "$test_id" "$branch_name" "$correct_result" "$command" "$test_dir"
    fi
  done < "$ASSERT_DATA_FILE"
  _show_success_message "All test successfully finished"
}


run_all_tests || exit 1

# TODO run only tests for specified test_id
# TODO run only tests for specified fixture branch
