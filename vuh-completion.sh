#!/usr/bin/env bash

function _vuh_completion()
{
  latest="${COMP_WORDS[$COMP_CWORD]}"
  # if there are no commands yet search for commands
  words="--help --version --configuration --update local-version main-version suggesting-version
         update-version module-root-path project-modules"

  # if command already typed so search for command's parameters
  for i in "${COMP_WORDS[@]}"; do
    case "$i" in
    -h|--help)
      words=""
      ;;
    -v|--version)
      words=""
      ;;
    --configuration)
      words=""
      ;;
    --update)
      words=""
      ;;
    lv|local-version)
      words="-q -pm= -cpm --current-project-module --quiet --dont-use-git --config-dir="
      ;;
    mv|main-version)
      words="-q -mb= -pm= -cpm --current-project-module --quiet --offline --airplane-mode --dont-use-git --config-dir="
      ;;
    sv|suggest-version)
      words="-q -v= -vp= -mb= -pm= -cpm --current-project-module --quiet --check-git-diff --dont-check-git-diff --offline --airplane-mode --dont-use-git --config-dir="
      ;;
    uv|update-version)
      words="-q -v= -vp= -mb= -pm= -cpm --current-project-module --quiet --check-git-diff --dont-check-git-diff --offline --airplane-mode --dont-use-git --config-dir="
#      words="'-q ' -v= -vp= -mb= -pm= '-cpm ' '--current-project-module ' '--quiet ' '--check-git-diff ' '--dont-check-git-diff ' '--offline ' '--airplane-mode ' '--dont-use-git ' --config-dir="
      ;;
    mrp|module-root-path)
      words="-q -pm= -cpm --current-project-module --quiet --dont-use-git --config-dir="
      ;;
    pm|project-modules)
      words="-q --quiet --dont-use-git --config-dir="
      ;;
    esac
  done

  # shellcheck disable=SC2207
  COMPREPLY=( $(compgen -W "$words" -- "$latest") )
}

complete -F _vuh_completion vuh
