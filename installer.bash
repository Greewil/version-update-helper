#!/usr/bin/env bash

# Output colors
NEUTRAL_COLOR='\e[0m'
RED='\e[1;31m'
YELLOW='\e[1;33m'

# Installer's global variables (Please don't modify!)
INSTALLATION_DIR=''
COMPLETION_DIR=''


function _show_function_title() {
  printf '\n'
  echo "$1"
}

function _show_error_message() {
  message=$1
  echo -en "$RED(vuh_installer : ERROR) $message$NEUTRAL_COLOR\n"
}

function _show_warning_message() {
  message=$1
  echo -en "$YELLOW(vuh : WARNING) $message$NEUTRAL_COLOR\n"
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

function _yes_no_question() {
  question_text=$1
  command_on_yes=$2
  command_on_no=$3
  asking_question='true'
  while [ $asking_question = 'true' ]; do
    read -p "$question_text (Y/N): " -r answer
    case "$answer" in
    y|Y|Yes|yes)
      ($command_on_yes)
      asking_question='false'
      ;;
    n|N|No|no)
      ($command_on_no)
      asking_question='false'
      ;;
    esac
  done
}

function _check_vuh_version() {
  installed_vuh_version=$(vuh -v) || return 1
  available_vuh_version=$(./vuh.bash -v) || return 1
  if [ "$installed_vuh_version" = "$available_vuh_version" ]; then
    _show_function_title 'vuh was successfully installed'
  else
    _show_error_message "Something went wrong!"
    _show_warning_message "You still have an old version ($installed_vuh_version) instead of new ($available_vuh_version)!"
    return 1
  fi
}

function _install() {
  # check PATH variable for INSTALLATION_DIR path
  if [ "$(echo "$PATH" | grep "$INSTALLATION_DIR")" = '' ]; then
    _show_error_message "Your won't be able to use vuh after installing it in $INSTALLATION_DIR!"
    _show_error_message "Make sure that $INSTALLATION_DIR is in your PATH variable and launch installer.bash again!"
    exit 1
  fi

  # install vuh
  mkdir -p "$INSTALLATION_DIR" || exit 1
  cp -f vuh.bash "$INSTALLATION_DIR/vuh" || exit 1

  # install autocompletion script
  mkdir -p "$COMPLETION_DIR" || exit 1
  if [ "$COMPLETION_DIR" = "$HOME/bash_completion.d" ]; then
    completion_file_name='vuh-completion.bash'
  else
    completion_file_name='vuh'
  fi
  cp -f vuh-completion.bash "$COMPLETION_DIR/$completion_file_name" || exit 1

  # check is vuh installed properly
  _check_vuh_version || exit 1

  # advice to restart current bash terminal session
  question_text="To activate vuh-completion your should restart bash terminal session. Do you want to restart it now?"
  _yes_no_question "$question_text" \
    "_try_to_restart_terminal" \
    "_warning_should_restart"
}

function _install_msys() {
  if [ -n "$HOME" ]; then
    # define dirs for msys terminal case (f.e. GitBash)
    INSTALLATION_DIR="$HOME/bin"
    COMPLETION_DIR="$HOME/bash_completion.d"
    _install
  else
    _show_error_message "HOME variable not found! aborting"
    exit 1
  fi
}

function _install_unix_like() {
  if [ -n "$HOME" ]; then
    # define dirs for msys terminal case (f.e. GitBash)
    INSTALLATION_DIR="/usr/bin"
    COMPLETION_DIR="/usr/share/bash-completion/completions"
    _install
  else
    _show_error_message "HOME variable not found! aborting"
    exit 1
  fi
}

function _ask_default_unix_like_installation() {
  os_type_name=$1
  echo "Your OS type was identified as $os_type_name"
  question_text="Do you want to start default installation for UNIX-like systems?"
  _yes_no_question "$question_text" \
    "_install_unix_like" \
    "_manual_installation"
}

function _manual_installation() {
  _show_function_title "manual installation"
}

function try_select_os_and_install() {
  case "$OSTYPE" in
    solaris*)
      _ask_default_unix_like_installation "SOLARIS" ;;
    linux*)
      _ask_default_unix_like_installation "linux" ;;
    bsd*)
      _ask_default_unix_like_installation "BSD" ;;
    darwin*)
      _ask_default_unix_like_installation "OSX" ;;
    msys*)
      echo "Seems like you running under msys (f.e. GitBash terminal)"
      question_text="Do you want to start default installation for msys?"
      _yes_no_question "$question_text" \
        "_install_msys" \
        "_manual_installation"
      ;;
    cygwin*)
      _ask_default_unix_like_installation "cygwin" ;;
    *)
      _show_error_message "Unknown OS type: $OSTYPE"
      _manual_installation
      ;;
  esac
}

try_select_os_and_install
