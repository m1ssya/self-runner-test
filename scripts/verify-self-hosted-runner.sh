#!/usr/bin/env bash

set -Eeuo pipefail

readonly expected_os="${EXPECTED_RUNNER_OS:-Linux}"
readonly expected_arch="${EXPECTED_RUNNER_ARCH:-X64}"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_environment_variable() {
  local name="$1"

  if [[ -z "${!name:-}" ]]; then
    fail "Required environment variable ${name} is not set."
  fi
}

assert_equal() {
  local description="$1"
  local expected="$2"
  local actual="$3"

  if [[ "$actual" != "$expected" ]]; then
    fail "${description}: expected '${expected}', got '${actual}'."
  fi
}

for name in \
  RUNNER_NAME \
  RUNNER_OS \
  RUNNER_ARCH \
  GITHUB_EVENT_NAME \
  GITHUB_REF \
  GITHUB_SHA \
  GITHUB_WORKSPACE; do
  require_environment_variable "$name"
done

assert_equal "Runner operating system" "$expected_os" "$RUNNER_OS"
assert_equal "Runner architecture" "$expected_arch" "$RUNNER_ARCH"

readonly kernel_name="$(uname -s)"
assert_equal "Kernel name" "Linux" "$kernel_name"

case "$GITHUB_EVENT_NAME" in
  pull_request | push | workflow_dispatch) ;;
  *) fail "Unsupported GitHub event '${GITHUB_EVENT_NAME}'." ;;
esac

command -v git >/dev/null 2>&1 || fail "git is not available on PATH."
command -v bash >/dev/null 2>&1 || fail "bash is not available on PATH."

cd "$GITHUB_WORKSPACE"

readonly checked_out_sha="$(git rev-parse HEAD)"
assert_equal "Checked-out commit" "$GITHUB_SHA" "$checked_out_sha"

printf 'Linux self-hosted runner verification passed.\n'
printf 'Runner name: %s\n' "$RUNNER_NAME"
printf 'Runner OS: %s\n' "$RUNNER_OS"
printf 'Runner architecture: %s\n' "$RUNNER_ARCH"
printf 'Event: %s\n' "$GITHUB_EVENT_NAME"
printf 'Ref: %s\n' "$GITHUB_REF"
printf 'SHA: %s\n' "$GITHUB_SHA"
printf 'Workspace: %s\n' "$GITHUB_WORKSPACE"
printf 'Kernel: %s\n' "$(uname -a)"
printf 'Git: %s\n' "$(git --version)"
printf 'Bash: %s\n' "${BASH_VERSION}"
printf 'CPU count: %s\n' "$(getconf _NPROCESSORS_ONLN)"
printf 'Disk usage:\n'
df -h "$GITHUB_WORKSPACE"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    printf '## Linux self-hosted runner verification\n\n'
    printf '| Field | Value |\n'
    printf '| --- | --- |\n'
    printf '| Runner | `%s` |\n' "$RUNNER_NAME"
    printf '| OS | `%s` |\n' "$RUNNER_OS"
    printf '| Architecture | `%s` |\n' "$RUNNER_ARCH"
    printf '| Event | `%s` |\n' "$GITHUB_EVENT_NAME"
    printf '| Ref | `%s` |\n' "$GITHUB_REF"
    printf '| SHA | `%s` |\n' "$GITHUB_SHA"
  } >>"$GITHUB_STEP_SUMMARY"
fi
