#!/usr/bin/env bash

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
    asking_question='true'
    while [ $asking_question = 'true' ]; do
      read -p "To activate vuh-completion your should restart bash terminal session. Do you want to restart it now? (Y/N): " -r answer
      case "$answer" in
      y|Y|Yes|yes)
        echo 'restarting current bash terminal session ...'
        exec bash -l || exit 1
        ;;
      n|N|No|no)
        echo 'Autocompletion will be available only after restarting your terminal!'
        exit 0
        ;;
      esac
    done
  else
    echo "HOME variable not found! aborting"
    exit 1
  fi
}

install_for_gitbash
