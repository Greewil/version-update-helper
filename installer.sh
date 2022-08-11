#!/usr/bin/env bash

# Installer configuration
INSTALLING_APP_NAME='vuh'

# Output colors
APP_NAME='vuh_installer'
NEUTRAL_COLOR='\e[0m'
RED='\e[1;31m'        # for errors
YELLOW='\e[1;33m'     # for warnings
BROWN='\e[0;33m'      # for inputs
LIGHT_CYAN='\e[1;36m' # for changes

# Variables from input parameters
DEFAULT_INSTALLATION='false'

# Installer's global variables (Please don't modify!)
INSTALLATION_DIR=''
COMPLETION_DIR=''
DATA_DIR=''


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
  while [ "$asking_question" = 'true' ]; do
    read -p "$(echo -e "$BROWN($APP_NAME : INPUT) $question_text (Y/N): $NEUTRAL_COLOR")" -r answer
    case "$answer" in
    y|Y|Yes|yes)
      eval "$command_on_yes"
      asking_question='false'
      ;;
    n|N|No|no)
      eval "$command_on_no"
      asking_question='false'
      ;;
    esac
  done
}

function _get_input() {
  ask_input_message=$1
  output_variable_name=$2
  read -p "$(echo -e "$BROWN($APP_NAME : INPUT) $ask_input_message: $NEUTRAL_COLOR")" -r "$output_variable_name"
}

# Ask user to write input string and checks it.
# Asks input until check_function ($3) returns true.
#
# $1 - Message that asks an input from user
# $2 - Output variable name in which function should leave the result
# $3 - Function that returns 1 if input was incorrect and user should write it again.
# $4 - Message that will be shown if check_function ($3) will return 1
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
    eval "$check_function ${!output_variable}" || {
      waiting_for_input='true'
      _show_warning_message "'${!output_variable}': $check_failed_message"
    }
  done
}

function _get_script_source_path() {
  source_path=${BASH_SOURCE[0]}
  while [ -L "$source_path" ]; do # resolve $source_path until the file is no longer a symlink
    output=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
    source_path=$(readlink "$source_path")
    [[ $source_path != /* ]] && source_path=$output/$source_path # if $source_path was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  output=$( cd -P "$( dirname "$source_path" )" >/dev/null 2>&1 && pwd )
  echo "$output"
}

function _warning_should_restart() {
  _show_warning_message 'Autocompletion will be available only after restarting your shell session!'
}

function _check_installed_version() {
  # get installer path in case if installer started not from the same directory
  installer_path=$(_get_script_source_path) || return 1
  installed_version=$($INSTALLING_APP_NAME -v) || return 1
  available_version=$("$installer_path/vuh.sh" -v) || return 1
  if [ "$installed_version" = "$available_version" ]; then
    _show_updated_message "$INSTALLING_APP_NAME was successfully installed"
  else
    _show_error_message "$INSTALLING_APP_NAME version check failed! Something went wrong ..."
    _show_warning_message "You still have an old version ($installed_version) instead of new ($available_version)!"
    return 1
  fi
}

function _install() {
  # get installer path in case if installer started not from the same directory
  installer_path=$(_get_script_source_path)

  # check PATH variable for INSTALLATION_DIR path
  if [ "$(echo "$PATH" | grep ":$INSTALLATION_DIR:")" = '' ]; then
    _show_error_message "($INSTALLATION_DIR not found in PATH)"
    _show_error_message "Your won't be able to use $INSTALLING_APP_NAME from any place!"
    _show_error_message "Make sure that $INSTALLATION_DIR is in your PATH variable and launch installer.sh again!"
    _yes_no_question "Do you still want to install $INSTALLING_APP_NAME in $INSTALLATION_DIR?" "" "return 1" || return 1
  fi

  # install application
  mkdir -p "$INSTALLATION_DIR" || return 1
  cp -f "$installer_path/vuh.sh" "$INSTALLATION_DIR/$INSTALLING_APP_NAME" || return 1

  # install autocompletion script
  mkdir -p "$COMPLETION_DIR" || return 1
  cp -f "$installer_path/vuh-completion.sh" "$COMPLETION_DIR/$COMPLETION_SCRIPT_NAME" || return 1

  # create data dir and configuration files
  mkdir -p "$DATA_DIR" || return 1
  echo "# configuration file path: $DATA_DIR/installation_info.conf" > "$DATA_DIR/installation_info.conf"
  echo "" >> "$DATA_DIR/installation_info.conf"

  # write information about all installed files
  installation_dir_info="INSTALLATION_DIR='$INSTALLATION_DIR'"
  echo "$installation_dir_info" >> "$DATA_DIR/installation_info.conf" || return 1
  completion_dir_info="COMPLETION_DIR='$COMPLETION_DIR'"
  echo "$completion_dir_info" >> "$DATA_DIR/installation_info.conf" || return 1
  completion_script_name_info="COMPLETION_SCRIPT_NAME='$COMPLETION_SCRIPT_NAME'"
  echo "$completion_script_name_info" >> "$DATA_DIR/installation_info.conf" || return 1

  # create latest_update_check file
  touch "$DATA_DIR/latest_update_check"
  chmod 666 "$DATA_DIR/latest_update_check"

  # update DATA_DIR variable in application
  installed_script=$(<"$INSTALLATION_DIR/$INSTALLING_APP_NAME") || {
    _show_error_message "Failed to get file $INSTALLATION_DIR/$INSTALLING_APP_NAME!"
    return 1
  }
  string_to_replace='<should_be_replace_after_installation:DATA_DIR>'
  echo "${installed_script/$string_to_replace/$DATA_DIR}" > "$INSTALLATION_DIR/$INSTALLING_APP_NAME" || return 1

  # check is application installed properly
  _check_installed_version || return 1

  # warning to restart completion script
  _warning_should_restart || return 1
}

function _is_dir_exists() {
  dir=$1
  if [ ! -d "$dir" ]; then
    return 1
  fi
}

function _is_installation_dir_ok() {
  dir=$1
  _is_dir_exists "$dir" || return 1
  path_grep=$(echo "$PATH" | grep -E "$dir")
  if [ "$path_grep" = '' ]; then
    return 1
  fi
}

function _manual_select_installation_dir() {
  _show_function_title "select installation directory"
  recommended_dir="$INSTALLATION_DIR"
#  ask_input_message="Enter directory path where you want to install $INSTALLING_APP_NAME (recommended: $recommended_dir)" TODO add recommended dir
  ask_input_message="Enter directory path where you want to install $INSTALLING_APP_NAME"
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
#  recommended_dir="$COMPLETION_DIR"
#  ask_input_message="Enter directory path where you want to install autocompletion script for $INSTALLING_APP_NAME (recommended: $recommended_dir)" TODO add recommended dir
  ask_input_message="Enter directory path where you want to install autocompletion script for $INSTALLING_APP_NAME"
  output_variable_name="COMPLETION_DIR"
  check_function="_is_dir_exists"
  check_failed_message="Directory doesn't exist! Please select another directory or create this one!"
  _get_input_with_check "$ask_input_message" "$output_variable_name" "$check_function" "$check_failed_message"
  echo "directory for autocompletion script selected: $COMPLETION_DIR"
  COMPLETION_SCRIPT_NAME="$INSTALLING_APP_NAME"
#  _get # TODO check if user want COMPLETION_SCRIPT_NAME to be $INSTALLING_APP_NAME or $INSTALLING_APP_NAME-completion.bash
}

function _manual_select_data_dir() {
  _show_function_title "select directory where script should store its configuration and other temporary data"
#  recommended_dir="$DATA_DIR"
#  ask_input_message="Enter directory path where you want to store information about $INSTALLING_APP_NAME script (recommended: $recommended_dir)" TODO add recommended dir
  ask_input_message="Enter directory path where you want to store information about $INSTALLING_APP_NAME script"
  output_variable_name="DATA_DIR"
  check_function="_is_dir_exists"
  check_failed_message="Directory doesn't exist! Please select another directory or create this one!"
  _get_input_with_check "$ask_input_message" "$output_variable_name" "$check_function" "$check_failed_message"
  DATA_DIR="$DATA_DIR/$INSTALLING_APP_NAME"
  echo "configuration directory for autocompletion script selected: $DATA_DIR"
}

function _manual_installation() {
  [ $DEFAULT_INSTALLATION = 'true' ] && {
    _show_error_message "Default installation failed!"
    exit 1
  }
  _show_function_title "manual installation"
  _manual_select_installation_dir || return 1
  _manual_select_completion_dir || return 1
  _manual_select_data_dir || return 1
  _install || return 1
}

function _install_msys() {
  if [ -n "$HOME" ]; then
    _show_function_title "Installing for msys ..."
    INSTALLATION_DIR="$HOME/bin"
    COMPLETION_DIR="$HOME/bash_completion.d"
    COMPLETION_SCRIPT_NAME="$INSTALLING_APP_NAME-completion.bash"
    DATA_DIR="$HOME/bin/$INSTALLING_APP_NAME-data"
    _install || return 1
  else
    _show_error_message "HOME variable not found! aborting"
    exit 1
  fi
}

function _install_unix_like() {
  _show_function_title "Installing for unix-like OS ($OSTYPE) ..."
  INSTALLATION_DIR="/usr/bin"
  if [ -d /usr/share/bash-completion/completions ]; then
    COMPLETION_DIR="/usr/share/bash-completion/completions"
    COMPLETION_SCRIPT_NAME="$INSTALLING_APP_NAME"
  else
    _show_error_message "Couldn't find bash-completion directory!"
    echo "Please select bash-completion directory manually"
    _manual_select_completion_dir || return 1
  fi
  DATA_DIR="/usr/share/$INSTALLING_APP_NAME"
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

function _ask_default_msys_installation() {
  echo "Seems like you using msys"
  question_text="Do you want to start default installation for msys (f.e. if you using GitBash terminal)?"
  _yes_no_question "$question_text" "_install_msys" "_manual_installation" || {
    _show_error_message "Something went wrong due installation!"
    exit 1
  }
}

function try_select_os_and_install() {
  case "$OSTYPE" in
    solaris*)
      [ $DEFAULT_INSTALLATION = 'true' ] && _install_unix_like
      [ $DEFAULT_INSTALLATION = 'false' ] && _ask_default_unix_like_installation "SOLARIS"
      ;;
    linux*)
      [ $DEFAULT_INSTALLATION = 'true' ] && _install_unix_like
      [ $DEFAULT_INSTALLATION = 'false' ] && _ask_default_unix_like_installation "linux"
      ;;
    bsd*)
      [ $DEFAULT_INSTALLATION = 'true' ] && _install_unix_like
      [ $DEFAULT_INSTALLATION = 'false' ] && _ask_default_unix_like_installation "BSD"
      ;;
    cygwin*)
      [ $DEFAULT_INSTALLATION = 'true' ] && _install_unix_like
      [ $DEFAULT_INSTALLATION = 'false' ] && _ask_default_unix_like_installation "cygwin"
      ;;
    darwin*)
      [ $DEFAULT_INSTALLATION = 'true' ] && _install_unix_like
      [ $DEFAULT_INSTALLATION = 'false' ] && _ask_default_unix_like_installation "OSX"
      ;;
    msys*)
      [ $DEFAULT_INSTALLATION = 'true' ] && _install_msys
      [ $DEFAULT_INSTALLATION = 'false' ] && _ask_default_msys_installation
      ;;
    *)
      _show_error_message "Unknown OS type: $OSTYPE"
      _manual_installation || exit 1
      ;;
  esac
}

if [ "$1" = '-d' ]; then
  DEFAULT_INSTALLATION='true'
fi

try_select_os_and_install $$ exit 0
