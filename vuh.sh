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
#/        [-mb=<version>]          to use another main branch (instead of main branch specified in .conf file)
#/     sv, suggesting-version   show suggesting version which this branch should use
#/        [-v=<version>]           to specify your own version which also will be taken into account
#/        [-mb=<version>]          to use another main branch (instead of main branch specified in .conf file)
#/     uv, update-version       replace your local version with suggesting version which this branch should use
#/        [-v=<version>]           to specify your own version which also will be taken into account
#/        [-mb=<version>]          to use another main branch (instead of main branch specified in .conf file)
#/
#/ Suggest relevant version for your current project or even update your local project's version.
#/ Script can work with your project's versions from any directory inside of your local repository.
#
# Written by Shishkin Sergey <shishkin.sergey.d@gmail.com>

# Current version of version_manager.sh.
VUH_VERSION='0.1.0'

# Output colors
APP_NAME='vuh'
NEUTRAL_COLOR='\e[0m'
RED='\e[1;31m'        # for errors
YELLOW='\e[1;33m'     # for warnings
BROWN='\e[0;33m'      # for inputs
LIGHT_CYAN='\e[1;36m' # for changes

# Vuh's global variables (Please don't modify!)
LOADED_CONF_FILE_VERSION=''
ROOT_REPO_DIR=''
LOCAL_VERSION=''
MAIN_VERSION=''
SUGGESTING_VERSION=''

# Console input variables (Please don't modify!)
COMMAND=''
SPECIFIED_VERSION=''
SPECIFIED_MAIN_BRANCH=''
SPECIFIED_AGREEMENT='false'


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

function _show_invalid_usage_error_message() {
  message=$1
  _show_error_message "$message"
  echo 'Use "vuh --help" to see available commands and options information'
}

function _exit_if_using_multiple_commands() {
  last_command=$1
  if [ "$COMMAND" != '' ]; then
    _show_invalid_usage_error_message "You can't use both commands: '$COMMAND' and '$1'!"
    exit 1
  fi
}

function _check_arg() {
  arg="$1"
  if [ "$COMMAND" = '' ]; then
    _show_invalid_usage_error_message "Parameter '$1' used without specifying any command!"
    exit 1
  fi
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

function _load_project_variables_from_config() {
  config_file=$1
  tmp_conf_file="/tmp/vuh_projects_conf_file.conf"
  echo "$config_file" > $tmp_conf_file
  . $tmp_conf_file || {
    rm -f /tmp/vuh_projects_conf_file.conf
    return 1
  }
  rm -f /tmp/vuh_projects_conf_file.conf
}

function _check_version_syntax() {
  version=$1
  if [ "$version" = "" ] || [[ $(echo "$version" | grep "$VERSION_REG_EXP") != "$version" ]]; then
    return 1
  fi || return 1
}

function _get_syncing_versions() {
  full_version=$1
  syncing_versions=${full_version%.*} || return 1
  [ "$syncing_versions" != '' ] || return 1
  echo "$syncing_versions"
}

function _get_major_version() {
  full_version=$1
  major_version=${full_version%%.*}
  [ "$major_version" != '' ] || return 1
  echo "$major_version"
}

function _get_module_version() {
  full_version=$1
  syncing_versions=$(_get_syncing_versions "$full_version") || return 1
  module_version=${syncing_versions##*.} || return 1
  [ "$module_version" != '' ] || return 1
  echo "$module_version"
}

function _get_minor_version() {
  full_version=$1
  minor_version=${full_version##*.} || return 1
  [ "$minor_version" != '' ] || return 1
  echo "$minor_version"
}

function _get_largest_version() {
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

function _get_incremented_version() {
  v=$1
  v_syncing_versions=$(_get_syncing_versions "$v") || return 1
  v_minor_version=$(( $(_get_minor_version "$v") + 1 )) || return 1
  echo "$v_syncing_versions.$v_minor_version"
}

function _get_root_repo_dir() {
  ROOT_REPO_DIR=$(git rev-parse --show-toplevel) || {
    _show_error_message "Can't find root repo directory!"
    echo
    return 1
  }
}

function _get_version_from_file() {
  version_file=$1
  version=$(echo "$version_file" | grep "$TEXT_BEFORE_VERSION_CODE" | grep "$TEXT_AFTER_VERSION_CODE")
  version=${version##*$TEXT_BEFORE_VERSION_CODE} || return 1
  if [[ "$TEXT_AFTER_VERSION_CODE" != '' ]]; then
    version=${version%%$TEXT_AFTER_VERSION_CODE*} || return 1
  fi
  _check_version_syntax "$version" || return 1
  echo "$version"
}

function _fetch_remote_branches() {
  git fetch || {
    _show_error_message 'Failed to use "git fetch" to update information about remote branches!'
    _show_error_message 'If git threw "Permission denied (publickey)" then maybe you should configure public keys.'
    return 1
  }
}

function _unset_conf_variables() {
  # vuh-0.1.0
  MAIN_BRANCH_NAME='NO_MAIN_BRANCH_NAME'
  VERSION_FILE='NO_VERSION_FILE'
  TEXT_BEFORE_VERSION_CODE='NO_TEXT_BEFORE_VERSION_CODE'
  TEXT_AFTER_VERSION_CODE='NO_TEXT_AFTER_VERSION_CODE'
  VERSION_REG_EXP='NO_VERSION_REG_EXP'
}

# Checks compatibility of vuh and loaded configuration file.
# Throws an error if some of default variables wasn't loaded at all.
#
# Returns nothing.
function _check_conf_data_version() {
  # vuh-0.1.0
  if [ "$MAIN_BRANCH_NAME" = 'NO_MAIN_BRANCH_NAME' ] ||
      [ "$VERSION_FILE" = 'NO_VERSION_FILE' ] ||
      [ "$TEXT_BEFORE_VERSION_CODE" = 'NO_TEXT_BEFORE_VERSION_CODE' ] ||
      [ "$TEXT_AFTER_VERSION_CODE" = 'NO_TEXT_AFTER_VERSION_CODE' ] ||
      [ "$VERSION_REG_EXP" = 'NO_VERSION_REG_EXP' ]; then
    _show_error_message "Configuration test failed! Configuration variables were empty or weren't loaded at all!"
    return 1
  else
    LOADED_CONF_FILE_VERSION='0.1.0'
  fi
}

function _load_local_conf_file() {
  _unset_conf_variables || return 1
  _get_root_repo_dir || return 1
  conf_file=$(<"$ROOT_REPO_DIR/vuh.conf") || {
    _show_error_message "Failed to read local configuration file $ROOT_REPO_DIR/vuh.conf!"
    return 1
  }
  _load_project_variables_from_config "$conf_file" || {
    _show_error_message "Failed to load variables from local configuration file $ROOT_REPO_DIR/vuh.conf!"
    return 1
  }
  _check_conf_data_version || return 1
}

function _load_remote_conf_file() {
  _unset_conf_variables || return 1
  branch_name=$1
  main_branch_config_file=$(git show "origin/$branch_name:vuh.conf") || {
    _show_error_message "Failed to read remote configuration file origin/$branch_name:vuh.conf!"
    return 1
  }
  _load_project_variables_from_config "$main_branch_config_file" || {
    _show_error_message "Failed to load variables from remote configuration file origin/$branch_name:vuh.conf!"
    return 1
  }
  _check_conf_data_version || return 1
}

function _show_suggested_versions_comparison() {
  if [ "$SUGGESTING_VERSION" = "$LOCAL_VERSION" ]; then
    echo "(your local version seems to be ok)"
  elif [ "$SUGGESTING_VERSION" = "$SPECIFIED_VERSION" ]; then
    echo "(specified version seems to be ok)"
  else
    echo "(suggested to use new version)"
  fi
}

function read_local_version() {
  _show_function_title 'getting local version'
  _load_local_conf_file || exit 1
  version_file=$(<"$ROOT_REPO_DIR/$VERSION_FILE") || {
    _show_error_message "Failed to load file $ROOT_REPO_DIR/$VERSION_FILE!"
    exit 1
  }
  LOCAL_VERSION=$(_get_version_from_file "$version_file") || {
    _show_error_message "Failed to get local version from $ROOT_REPO_DIR/$VERSION_FILE!"
    check_line_command='cat (VERSION_FILE_NAME) | grep "(config:TEXT_BEFORE_VERSION_CODE)" | grep '\
'"(config:TEXT_AFTER_VERSION_CODE)"'
    _show_error_message "Make sure that command ($check_line_command) will throw the line with your version"
    check_version_command='echo YOUR_VERSION_EXAMPLE | grep "(config:VERSION_REG_EXP)"'
    _show_error_message "Also make sure that command ($check_version_command) will throw same YOUR_VERSION_EXAMPLE"
    exit 1
  }
  echo "local: $LOCAL_VERSION"
}

function read_main_version() {
  _show_function_title 'getting main version'
  _load_local_conf_file || exit 1
  remote_branch=$MAIN_BRANCH_NAME
  if [[ "$SPECIFIED_MAIN_BRANCH" != '' ]]; then
    remote_branch="$SPECIFIED_MAIN_BRANCH" || {
      _show_error_message "Failed to set specified main branch '$SPECIFIED_MAIN_BRANCH'!"
      exit 1
    }
  fi
  _fetch_remote_branches || exit 1
  handling_file="origin/$remote_branch:$VERSION_FILE"
  _load_remote_conf_file "$remote_branch" || {
    _show_warning_message "vuh will use local configuration to get remote version from origin/$remote_branch"
    _load_local_conf_file || exit 1
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
    check_line_command='cat (VERSION_FILE_NAME) | grep "(config:TEXT_BEFORE_VERSION_CODE)" | grep '\
'"(config:TEXT_AFTER_VERSION_CODE)"'
    _show_error_message "Make sure that command ($check_line_command) will throw the line with your version"
    check_version_command='echo YOUR_VERSION_EXAMPLE | grep "(config:VERSION_REG_EXP)"'
    _show_error_message "Also make sure that command ($check_version_command) will throw same YOUR_VERSION_EXAMPLE"
    exit 1
  }
  echo "origin/$remote_branch: $MAIN_VERSION"
}

function get_suggesting_version() {
  read_local_version || exit 1
  read_main_version || exit 1
  _show_function_title 'suggesting relevant version'
  largest_version=$(_get_largest_version "$MAIN_VERSION" "$LOCAL_VERSION") || {
    _show_error_message "Failed to select larger version between '$MAIN_VERSION' and '$LOCAL_VERSION'!"
    exit 1
  }
  if [[ "$SPECIFIED_VERSION" != '' ]]; then
    largest_version=$(_get_largest_version "$largest_version" "$SPECIFIED_VERSION") || {
      _show_error_message "Failed to select larger version between '$largest_version' and '$SPECIFIED_VERSION'!"
      exit 1
    }
  fi
  if [ "$largest_version" = "$MAIN_VERSION" ]; then
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

function update_version() {
  new_version=$1
  _show_function_title 'updating local version'
  _load_local_conf_file || exit 1
  version_file=$(<"$ROOT_REPO_DIR/$VERSION_FILE") || {
    _show_error_message "Failed to load file $ROOT_REPO_DIR/$VERSION_FILE!"
    exit 1
  }
  if [ "$LOCAL_VERSION" != "$new_version" ]; then
    old_version_string="$TEXT_BEFORE_VERSION_CODE$LOCAL_VERSION$TEXT_AFTER_VERSION_CODE"
    new_version_string="$TEXT_BEFORE_VERSION_CODE$new_version$TEXT_AFTER_VERSION_CODE"
    echo "${version_file/$old_version_string/$new_version_string}" > "$ROOT_REPO_DIR/$VERSION_FILE"
    _show_updated_message "local version updated: $LOCAL_VERSION -> $new_version"
  else
    echo "your local version already up to date: $LOCAL_VERSION"
  fi
}

function show_vuh_version() {
  echo "vuh version: $VUH_VERSION"
}

function show_help() {
  grep '^#/' <"$0" | cut -c4-
}


_unset_conf_variables

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h|--help)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--help'
    shift ;;
  -v|--version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='--version'
    shift ;;
  lv|local-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='local-version'
    shift ;;
  mv|main-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='main-version'
    shift ;;
  sv|suggest-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='suggest-version'
    shift ;;
  uv|update-version)
    _exit_if_using_multiple_commands "$1"
    COMMAND='update-version'
    shift ;;
  -v=*)
    _check_arg "$1"
    SPECIFIED_VERSION=${1#*=}
    echo "SPECIFIED_VERSION=$SPECIFIED_VERSION"
    shift ;;
  -mb=*)
    _check_arg "$1"
    SPECIFIED_MAIN_BRANCH=${1#*=}
    shift ;;
  -y)
    _check_arg "$1"
    SPECIFIED_AGREEMENT='true'
    shift ;;
  -*|--*)
    _show_invalid_usage_error_message "Unknown option '$1'!"
    exit 1 ;;
  *)
    _show_invalid_usage_error_message "Unknown command '$1'!"
    exit 1 ;;
  esac
done

case "$COMMAND" in
--help)
  show_help
  exit 0
  ;;
--version)
  show_vuh_version
  exit 0
  ;;
local-version)
  read_local_version
  exit 0
  ;;
main-version)
  read_main_version
  exit 0
  ;;
suggest-version)
  get_suggesting_version
  exit 0
  ;;
update-version)
  get_suggesting_version
  update_version "$SUGGESTING_VERSION"
  exit 0
  ;;
esac
