#!/usr/bin/env bash

# Output colors
APP_NAME='vuh_installer'
NEUTRAL_COLOR='\e[0m'
RED='\e[1;31m'        # for errors
YELLOW='\e[1;33m'     # for warnings
BROWN='\e[0;33m'      # for inputs
LIGHT_CYAN='\e[1;36m' # for changes

# Installer's global variables (Please don't modify!)
INSTALLATION_DIR=''
COMPLETION_DIR=''


function _show_function_title() {
  printf '\n'
  echo "$1"
}

function _show_error_message() {
  message=$1
  echo -en "$RED($APP_NAME : ERROR) $message$NEUTRAL_COLOR\n"
}

function _show_warning_message() {
  message=$1
  echo -en "$YELLOW($APP_NAME : WARNING) $message$NEUTRAL_COLOR\n"
}

function _show_updated_message() {
  message=$1
  echo -en "$LIGHT_CYAN($APP_NAME : CHANGED) $message$NEUTRAL_COLOR\n"
}

function _yes_no_question() {
  question_text=$1
  command_on_yes=$2
  command_on_no=$3

  asking_question='true'
  echo -en "$BROWN"
  while [ "$asking_question" = 'true' ]; do
    read -p "($APP_NAME : INPUT) $question_text (Y/N): " -r answer
    case "$answer" in
    y|Y|Yes|yes)
      echo -en "$NEUTRAL_COLOR"
      ($command_on_yes)
      asking_question='false'
      ;;
    n|N|No|no)
      echo -en "$NEUTRAL_COLOR"
      ($command_on_no)
      asking_question='false'
      ;;
    esac
  done
}

function _get_input() {
  ask_input_message=$1
  output_variable_name=$2
  echo -en "$BROWN"
  read -p "($APP_NAME : INPUT) $ask_input_message: " -r "$output_variable_name"
  echo -en "$NEUTRAL_COLOR"
}

# Ask user to write input string and checks it.
# Asks input until check_function ($3) returns true.
#
# $1 - Message that asks an input from user
# $2 - Output variable name in which function should leave the result
# $3 - Function that returns 'true' if input was correct and 'false' if user should write it again.
# $4 - Message that will be shown if check_function ($3) will return 'false'
#
# Returns nothing.
function _get_input_with_check() {
  ask_input_message=$1
  output_variable=$2
  check_function=$3
  check_failed_message=$4

  waiting_for_input='true'
  while [ "$waiting_for_input" = 'true' ]; do
    _get_input "$ask_input_message" "$output_variable"
    waiting_for_input='false'
    $check_function "${!output_variable}" || {
      waiting_for_input='true'
      _show_warning_message "'${!output_variable}': $check_failed_message"
    }
  done
}

function _warning_should_restart() {
  _show_warning_message 'Autocompletion will be available only after restarting your terminal!'
}

function _try_to_restart_terminal() {
  _show_warning_message 'restarting current bash terminal session ...'
  exec bash -l || exec zsh -l || {
    _show_error_message "failed to restart current bash terminal session!"
    _warning_should_restart
    return 1
  }
}

function _check_vuh_version() {
  installed_vuh_version=$(vuh -v) || return 1
  available_vuh_version=$(./vuh.bash -v) || return 1
  if [ "$installed_vuh_version" = "$available_vuh_version" ]; then
    _show_updated_message 'Vuh was successfully installed'
  else
    _show_error_message "Vuh version check failed! Something went wrong ..."
    _show_warning_message "You still have an old version ($installed_vuh_version) instead of new ($available_vuh_version)!"
    return 1
  fi
}

function _install() {
  # check PATH variable for INSTALLATION_DIR path
  if [ "$(echo "$PATH" | grep "$INSTALLATION_DIR")" = '' ]; then
    _show_error_message "Your won't be able to use vuh after installing it in $INSTALLATION_DIR!"
    _show_error_message "Make sure that $INSTALLATION_DIR is in your PATH variable and launch installer.bash again!"
    return 1
  fi

  # install vuh
  mkdir -p "$INSTALLATION_DIR" || return 1
  cp -f vuh.bash "$INSTALLATION_DIR/vuh" || return 1

  # install autocompletion script
  mkdir -p "$COMPLETION_DIR" || return 1
  if [ "$COMPLETION_DIR" = "$HOME/bash_completion.d" ]; then
    completion_file_name='vuh-completion.bash'
  else
    completion_file_name='vuh'
  fi
  cp -f vuh-completion.bash "$COMPLETION_DIR/$completion_file_name" || return 1

  # check is vuh installed properly
  _check_vuh_version || return 1

  # advice to restart current bash terminal session
  question_text="To activate vuh-completion your should restart bash terminal session. Do you want to restart it now?"
  _yes_no_question "$question_text" \
    "_try_to_restart_terminal" \
    "_warning_should_restart" || return 1
}

function _is_dir_exists() {
  dir=$1
  if [ ! -d "$dir" ]; then
    return 1
  fi
}

function _is_installation_dir_ok() {
  dir=$1
  _is_dir_exists $dir || return 1
  path_grep=$(echo $PATH | egrep "$dir")
  if [ "$path_grep" = '' ]; then
    return 1
  fi
}

function _manual_select_installation_dir() {
  _show_function_title "select installation directory"
  recommended_dir="$INSTALLATION_DIR"
#  ask_input_message="Enter directory path where you want to install vuh (recommended: $recommended_dir)" TODO add recommended dir
  ask_input_message="Enter directory path where you want to install vuh"
  output_variable_name="INSTALLATION_DIR"
  check_function="_is_installation_dir_ok" # here should be PATH check
  _warning="Directory either doesn't exist or wasn't specified in PATH!"
  _suggestion="Select another directory or make sure that this one exists and specified in PATH!"
  check_failed_message="$_warning $_suggestion"
  _get_input_with_check "$ask_input_message" "$output_variable_name" "$check_function" "$check_failed_message"
  echo "installation directory selected: $INSTALLATION_DIR"
}

function _manual_select_completion_dir() {
  _show_function_title "select directory for autocompletion script"
  recommended_dir="$COMPLETION_DIR"
#  ask_input_message="Enter directory path where you want to install autocompletion script for vuh (recommended: $recommended_dir)" TODO add recommended dir
  ask_input_message="Enter directory path where you want to install autocompletion script for vuh"
  output_variable_name="COMPLETION_DIR"
  check_function="_is_dir_exists"
  check_failed_message="Directory doesn't exist! Please select another directory or create this one!"
  _get_input_with_check "$ask_input_message" "$output_variable_name" "$check_function" "$check_failed_message"
  echo "directory for autocompletion script selected: $COMPLETION_DIR"
}

function _manual_installation() {
  _show_function_title "manual installation"
  _manual_select_installation_dir || return 1
  _manual_select_completion_dir || return 1
  _install || return 1
}

function _install_msys() {
  if [ -n "$HOME" ]; then
    # define dirs for msys terminal case (f.e. GitBash)
    INSTALLATION_DIR="$HOME/bin"
    COMPLETION_DIR="$HOME/bash_completion.d"
    _install || return 1
  else
    _show_error_message "HOME variable not found! aborting"
    exit 1
  fi
}

function _install_unix_like() {
  # define dirs for UNIX-like case
  INSTALLATION_DIR="/usr/bin"
  if [ -d /usr/share/bash-completion/completions ]; then
    COMPLETION_DIR="/usr/share/bash-completion/completions"
  else
    _show_error_message "Couldn't find bash-completion directory!"
    echo "Please select bash-completion directory manually"
    _manual_select_completion_dir || return 1
  fi
  _install || return 1
}

function _ask_default_unix_like_installation() {
  os_type_name=$1
  echo "Your OS type was identified as $os_type_name"
  question_text="Do you want to start default installation for UNIX-like systems?"
  _yes_no_question "$question_text" "_install_unix_like" "_manual_installation" || {
    _show_error_message "Something went wrong due installation!"
    exit 1
  }
}

function try_select_os_and_install() {
  case "$OSTYPE" in
    solaris*)
      _ask_default_unix_like_installation "SOLARIS" ;;
    linux*)
      _ask_default_unix_like_installation "linux" ;;
    bsd*)
      _ask_default_unix_like_installation "BSD" ;;
    cygwin*)
      _ask_default_unix_like_installation "cygwin" ;;
    darwin*)
      _ask_default_unix_like_installation "OSX" ;;
    msys*)
      echo "Seems like you using msys"
      question_text="Do you want to start default installation for msys (f.e. if you using GitBash terminal)?"
      _yes_no_question "$question_text" "_install_msys" "_manual_installation" || {
        _show_error_message "Something went wrong due installation!"
        exit 1
      }
      ;;
    *)
      _show_error_message "Unknown OS type: $OSTYPE"
      _manual_installation || exit 1
      ;;
  esac
}

try_select_os_and_install
