#!/usr/bin/env bash

function _show_error_message {
  message=$1
  echo "(vuh_installer : ERROR) $message"
}

function _try_to_restart_terminal {
  echo 'restarting current bash terminal session ...'
  exec bash -l || exec zsh -l || {
    _show_error_message "failed to restart current bash terminal session!"
    echo 'Autocompletion will be available only after restarting your terminal!'
    return 1
  }
}

function _yes_no_question {
  question_text=$1
  command_on_yes=$2
  command_on_no=$3
  asking_question='true'
  while [ $asking_question = 'true' ]; do
    read -p "$question_text (Y/N): " -r answer
    case "$answer" in
    y|Y|Yes|yes)
      $command_on_yes
      asking_question='false'
      ;;
    n|N|No|no)
      $command_on_no
      exit 0
      ;;
    esac
  done
}

function install_for_gitbash {
  if [ -n "$HOME" ]; then
    # GitBash terminal case

    # install vuh
    mkdir -p "$HOME/bin" || exit 1
    cp -f vuh.bash "$HOME/bin/vuh" || exit 1

    # install autocompletion script
    mkdir -p "$HOME/bash_completion.d" || exit 1
    cp -f vuh-completion.bash "$HOME/bash_completion.d/vuh-completion.bash" || exit 1

    # show success message
    printf '\n'
    echo 'vuh was successfully installed'

    # advice to restart current bash terminal session
    question_text="To activate vuh-completion your should restart bash terminal session. Do you want to restart it now?"
    _yes_no_question "$question_text" \
      "_try_to_restart_terminal" \
      "echo Autocompletion will be available only after restarting your terminal!"
  else
    echo "HOME variable not found! aborting"
    exit 1
  fi
}

install_for_gitbash
