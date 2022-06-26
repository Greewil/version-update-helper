#!/usr/bin/env bash

function install_for_gitbash {
  if [ -n "$HOME" ]; then
    # GitBash terminal case

    # installing vuh
    mkdir -p "$HOME/bin" || exit 1
    cp -f vuh.bash "$HOME/bin/vuh" || exit 1

    # installing autocompletion script
    mkdir -p "$HOME/bash_completion.d" || exit 1
    cp -f vuh-completion.bash "$HOME/bash_completion.d/vuh-completion.bash" || exit 1

    # show success message
    printf '\n'
    echo 'vuh was successfully installed'
    echo 'Autocompletion will be available only after restarting your terminal!'
  else
    echo "HOME variable not found! aborting"
    exit 1
  fi
}

install_for_gitbash
