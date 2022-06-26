#!/usr/bin/env bash

#/ Usage: vuh [-v | --version] [-h | --help] <command> [<args>]
#/
#/ Options:
#/     -h, --help               show help text
#/     -v, --version            show version
#/
#/ Commands:
#/     lv, local-version        show local current version (default format)
#/     mv, main-version         show version of origin/MAIN_BRANCH_NAME
#/     sv, suggesting-version   show suggesting version which this branch should use
#/        [-v=<version>]           to specify your own version which also will be taken into account
#/
#/ Suggest relevant version for your current project or even update your local project's version.
#
# Written by Shishkin Sergey <shishkin.sergey.d@gmail.com>

# Current version of version_manager.sh.
VERSION_MANAGER_VERSION="0.1.1"

# ------------------------------------- custom project parameters ------------------------------------- #
# MAIN_BRANCH_NAME:
#   the name of the main project's branch
# example: 'main' or 'master'
MAIN_BRANCH_NAME='master'
# VERSION_FILE:
#   file which contains version information (As in current branch so and in origin/MAIN_BRANCH_NAME branch!)
# example: 'package.json' (for node.js application)
VERSION_FILE='package.json'
# TEXT_BEFORE_VERSION_CODE:
#   unique text which will be just before version number (including spaces)
# example: '\"version\": \"' (for variable "version" in json files so it can find line "version": "1.6.2")
TEXT_BEFORE_VERSION_CODE='\"version\": \"'
# TEXT_AFTER_VERSION_CODE:
#   unique text which will be just after version number (including spaces)
# example: '\",' (for variable "version" in json files so it can find line "version": "1.6.2")
TEXT_AFTER_VERSION_CODE='\",'
# VERSION_REG_EXP:
#   regular expression which will work only on version number
# example: '^[0-9]\+\.[0-9]\+\.[0-9]\+$' (for versions like 1.63.20)
VERSION_REG_EXP='^[0-9]\+\.[0-9]\+\.[0-9]\+$'
# VERSION_UPDATE_COMMIT_TEXT:
#   regular expression which will work only on version number
# example: 'automatic version update (version_manager.sh)' (for versions like 1.63.20)
VERSION_UPDATE_COMMIT_TEXT='автоматическая накрутка версии (version_manager.sh)'
# ------------------------------------- custom project parameters ------------------------------------- #

CUR_DIR=$(pwd)
LOCAL_VERSION=''
MAIN_VERSION=''
SUGGESTING_VERSION=''

function _show_function_title {
  printf '\n'
  echo "$1"
}

function _check_version_syntax {
  version=$1
  if [ "$version" = "" ] || [[ $(echo "$version" | grep "$VERSION_REG_EXP") != "$version" ]]; then
    return 1
  fi || return 1
}

function _get_syncing_versions {
  full_version=$1
  syncing_versions=${full_version%.*} || return 1
  [ "$syncing_versions" != '' ] || return 1
  echo "$syncing_versions"
}

function _get_major_version {
  full_version=$1
  major_version=${full_version%%.*}
  [ "$major_version" != '' ] || return 1
  echo "$major_version"
}

function _get_module_version {
  full_version=$1
  syncing_versions=$(_get_syncing_versions "$full_version") || return 1
  module_version=${syncing_versions##*.} || return 1
  [ "$module_version" != '' ] || return 1
  echo "$module_version"
}

function _get_minor_version {
  full_version=$1
  minor_version=${full_version##*.} || return 1
  [ "$minor_version" != '' ] || return 1
  echo "$minor_version"
}

function _get_largest_version {
  v1=$1
  v2=$2
  v1_major=$(_get_major_version "$v1") || return 1
  v2_major=$(_get_major_version "$v2") || return 1
  v1_module=$(_get_module_version "$v1") || return 1
  v2_module=$(_get_module_version "$v2") || return 1
  v1_minor=$(_get_minor_version "$v1") || return 1
  v2_minor=$(_get_minor_version "$v2") || return 1
  if (( "$v1_major" == "$v2_major" )); then
    if (( "$v1_module" == "$v2_module" )); then
      if (( "$v1_minor" > "$v2_minor" )); then
        echo "$v1"
      else
        echo "$v2"
      fi
    elif (( "$v1_module" > "$v2_module" )); then
      echo "$v1"
    elif (( "$v1_module" < "$v2_module" )); then
      echo "$v2"
    fi
  elif (( "$v1_major" > "$v2_major" )); then
    echo "$v1"
  elif (( "$v1_major" < "$v2_major" )); then
    echo "$v2"
  fi || return 1
}

function _get_incremented_version {
  v=$1
  v_syncing_versions=$(_get_syncing_versions "$v") || return 1
  v_minor_version=$(( $(_get_minor_version "$v") + 1 )) || return 1
  echo "$v_syncing_versions.$v_minor_version"
}

function _get_version_from_file {
  version_file=$1
  version=${version_file##*$TEXT_BEFORE_VERSION_CODE} || return 1
  version=${version%%$TEXT_AFTER_VERSION_CODE*} || return 1
  _check_version_syntax "$version" || return 1
  echo "$version"
}

function _read_local_version {
  _show_function_title 'getting local version'
  version_file=$(<$VERSION_FILE) || {
    echo "Failed to load file $CUR_DIR/$VERSION_FILE!"
    return 1
  }
  LOCAL_VERSION=$(_get_version_from_file "$version_file") || {
    echo "Failed to get local version from $CUR_DIR/$VERSION_FILE!"
    return 1
  }
  echo "local: $LOCAL_VERSION"
}

function _read_main_version {
  _show_function_title 'getting main version'
  handling_file="origin/$MAIN_BRANCH_NAME:$VERSION_FILE"
  version_context=$(git show "$handling_file" | grep "$TEXT_BEFORE_VERSION_CODE") || {
    echo "Failed to load file $handling_file!"
    return 1
  }
  MAIN_VERSION=$(_get_version_from_file "$version_context") || {
    echo "Failed to get main version from $handling_file!"
    return 1
  }
  echo "main: $MAIN_VERSION"
}

function get_suggesting_version {
  _read_local_version || exit 1
  _read_main_version || exit 1
  _show_function_title 'suggesting relevant version'
  largest_version=$(_get_largest_version "$MAIN_VERSION" "$LOCAL_VERSION") || {
    echo "Failed to select larger version between '$MAIN_VERSION' and '$LOCAL_VERSION'!"
    exit 1
  }
  if [[ "$largest_version" = "$MAIN_VERSION" ]]; then
    SUGGESTING_VERSION=$(_get_incremented_version "$largest_version")
  else
    SUGGESTING_VERSION=$largest_version
  fi

  echo "suggesting: $SUGGESTING_VERSION"
  _check_version_syntax "$SUGGESTING_VERSION" || {
    echo "Suggesting version format is incorrect! Something went wrong ..."
    exit 1
  }
}

function show_vuh_version {
  echo "vuh version: $VERSION_MANAGER_VERSION"
}

function show_help {
  grep '^#/' <"$0" | cut -c4-
}

while [ "$#" != 0 ]; do
    case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        show_vuh_version
        exit 0
        ;;
    lv|local-version)
        _read_local_version
        exit 0
        ;;
    mv|main-version)
        _read_main_version
        exit 0
        ;;
    sv|suggesting-version)
        get_suggesting_version
        exit 0
        ;;
    -*|--*)
        echo >&2 "error: invalid option '$1'"
        echo 'use "vuh --help" to see available commands and options information'
        exit 1 ;;
    esac
done
