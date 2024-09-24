#!/usr/bin/env bash
complete -W "--help --version --configuration --update local-version main-version suggesting-version project-modules
update-version module-root-path --quiet --check-git-diff --dont-check-git-diff --offline --airplane-mode
--dont-use-git" vuh