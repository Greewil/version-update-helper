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
#/ Script can work with your project's versions from any directory of your local repository.
#
# Written by Shishkin Sergey <shishkin.sergey.d@gmail.com>

# Current version of version_manager.sh.
VUH_VERSION='0.1.0'

ROOT_REPO_DIR=''
LOCAL_VERSION=''
MAIN_VERSION=''
SPECIFIED_VERSION=''
SUGGESTING_VERSION=''

function _show_function_title {
  printf '\n'
  echo "$1"
}

function _show_error_message {
  message=$1
  echo "(vuh : ERROR) $message"
}

function _load_project_variables_from_config {
  config_file=$1
  tmp_conf_file="/tmp/vuh_projects_conf_file.conf"
  echo "$config_file" > $tmp_conf_file
  . $tmp_conf_file || {
    rm -f /tmp/vuh_projects_conf_file.conf
    return 1
  }
  rm -f /tmp/vuh_projects_conf_file.conf
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

function _get_root_repo_dir {
  ROOT_REPO_DIR=$(git rev-parse --show-toplevel) || {
    _show_error_message "Can't find root repo directory!"
    echo
    return 1
  }
}

function _get_version_from_file {
  version_file=$1
  version=${version_file##*$TEXT_BEFORE_VERSION_CODE} || return 1
  version=${version%%$TEXT_AFTER_VERSION_CODE*} || return 1
  _check_version_syntax "$version" || return 1
  echo "$version"
}

function _fetch_remote_branches {
  git fetch || {
    _show_error_message 'Failed to use "git fetch" to update information about remote branches!'
    _show_error_message 'If git threw "Permission denied (publickey)" then maybe you should configure public keys.'
    return 1
  }
}

function _load_local_conf_file {
  _get_root_repo_dir || return 1
  conf_file=$(<"$ROOT_REPO_DIR/vuh.conf") || {
    _show_error_message "Failed to read local configuration file $ROOT_REPO_DIR/vuh.conf!"
    return 1
  }
  _load_project_variables_from_config "$conf_file" || {
    _show_error_message "Failed to load variables from local configuration file $ROOT_REPO_DIR/vuh.conf!"
    return 1
  }
# TODO check is conf file actually loaded
# TODO check is conf file is correct
# TODO check is conf file has unsupported version
#  echo "env_vars:" "$MAIN_BRANCH_NAME" "$VERSION_FILE" "$TEXT_BEFORE_VERSION_CODE" "$TEXT_AFTER_VERSION_CODE" "$VERSION_REG_EXP"
}

function _load_remote_conf_file {
  branch_name=$1
  main_branch_config_file=$(git show "origin/$branch_name:vuh.conf") || {
    _show_error_message "Failed to read remote configuration file origin/$branch_name:vuh.conf!"
    return 1
  }
  _load_project_variables_from_config "$main_branch_config_file" || {
    _show_error_message "Failed to load variables from remote configuration file origin/$branch_name:vuh.conf!"
    return 1
  }
# TODO check is conf file actually loaded
# TODO check is conf file is correct
# TODO check is conf file has unsupported version
#  echo "env_vars:" "$MAIN_BRANCH_NAME" "$VERSION_FILE" "$TEXT_BEFORE_VERSION_CODE" "$TEXT_AFTER_VERSION_CODE" "$VERSION_REG_EXP"
}

function _show_suggested_versions_comparison {
  if [ "$SUGGESTING_VERSION" = "$LOCAL_VERSION" ]; then
    echo "(your local version seems to be ok)"
  elif [ "$SUGGESTING_VERSION" = "$SPECIFIED_VERSION" ]; then
    echo "(version specified in arguments seems to be ok)"
  else
    echo "(suggested to use new version)"
  fi
}

function read_local_version {
  _show_function_title 'getting local version'
  _load_local_conf_file || exit 1
  version_file=$(<"$ROOT_REPO_DIR/$VERSION_FILE") || {
    _show_error_message "Failed to load file $ROOT_REPO_DIR/$VERSION_FILE!"
    exit 1
  }
  LOCAL_VERSION=$(_get_version_from_file "$version_file") || {
    _show_error_message "Failed to get local version from $ROOT_REPO_DIR/$VERSION_FILE!"
    exit 1
  }
  echo "local: $LOCAL_VERSION"
}

function read_main_version {
  _show_function_title 'getting main version'
  _load_local_conf_file || exit 1
  _fetch_remote_branches || exit 1
  handling_file="origin/$MAIN_BRANCH_NAME:$VERSION_FILE"
  _load_remote_conf_file "$MAIN_BRANCH_NAME" || {
    _show_error_message "can't parse remote conf file"
#    TODO ask: Do you want to use local conf file for origin/main branch?
  }
  main_branch_file=$(git show "$handling_file") || {
    _show_error_message "Failed to load file $handling_file"
    exit 1
  }
  version_context=$(echo "$main_branch_file" | grep "$TEXT_BEFORE_VERSION_CODE") || {
    _show_error_message "Failed to get line, containing version from file $handling_file!"
    exit 1
  }
  MAIN_VERSION=$(_get_version_from_file "$version_context") || {
    _show_error_message "Failed to get main version from $handling_file!"
    exit 1
  }
  echo "main: $MAIN_VERSION"
}

function get_suggesting_version {
  read_local_version || exit 1
  read_main_version || exit 1
  _show_function_title 'suggesting relevant version'
  largest_version=$(_get_largest_version "$MAIN_VERSION" "$LOCAL_VERSION") || {
    _show_error_message "Failed to select larger version between '$MAIN_VERSION' and '$LOCAL_VERSION'!"
    exit 1
  }
  if [[ "$largest_version" = "$MAIN_VERSION" ]]; then
    SUGGESTING_VERSION=$(_get_incremented_version "$largest_version")
  else
    SUGGESTING_VERSION=$largest_version
  fi
  _show_suggested_versions_comparison
  echo "suggesting: $SUGGESTING_VERSION"
  _check_version_syntax "$SUGGESTING_VERSION" || {
    _show_error_message "Suggesting version format is incorrect! Something went wrong ..."
    exit 1
  }
}

function show_vuh_version {
  echo "vuh version: $VUH_VERSION"
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
    read_local_version
    exit 0
    ;;
  mv|main-version)
    read_main_version
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
