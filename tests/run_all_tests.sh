#!/usr/bin/env bash

# shellcheck disable=SC2034
STARTING_SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

cd "$STARTING_SCRIPT_DIR/unit-tests" || exit 1
./run_tests.sh || exit 1

cd "$STARTING_SCRIPT_DIR/integration-tests" || exit 1
./run_tests.sh || exit 1

cd "$STARTING_SCRIPT_DIR/installer-tests" || exit 1
./run_tests.sh ds 'installation-test' || exit 1
./run_tests.sh ds 'autoupdate-test' || exit 1
