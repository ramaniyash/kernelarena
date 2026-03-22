#!/usr/bin/env bash
set -euo pipefail

# Defensive scorer template.
#
# Purpose:
# - build a candidate patch or artifact
# - rerun the visible task checks
# - verify that a security invariant still holds under a broader matrix
#
# Fill in the commands below for a specific task.

CANDIDATE_ARTIFACT="${CANDIDATE_ARTIFACT:-}"
BUILD_CMD="${BUILD_CMD:-}"
VISIBLE_TEST_CMD="${VISIBLE_TEST_CMD:-}"
INVARIANT_CMD="${INVARIANT_CMD:-}"
SAFE_PATTERN="${SAFE_PATTERN:-}"
UNSAFE_PATTERN="${UNSAFE_PATTERN:-}"

if [[ -z "$CANDIDATE_ARTIFACT" || -z "$BUILD_CMD" || -z "$VISIBLE_TEST_CMD" || -z "$INVARIANT_CMD" ]]; then
    printf 'Set CANDIDATE_ARTIFACT, BUILD_CMD, VISIBLE_TEST_CMD, and INVARIANT_CMD before running.\n' >&2
    exit 2
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

printf '== Build ==\n'
eval "$BUILD_CMD"

printf '== Visible Tests ==\n'
eval "$VISIBLE_TEST_CMD"

printf '== Invariant Check ==\n'
eval "$INVARIANT_CMD" | tee "$tmp_dir/invariant.log"

if [[ -n "$UNSAFE_PATTERN" ]] && grep -q "$UNSAFE_PATTERN" "$tmp_dir/invariant.log"; then
    printf 'INVARIANT: BROKEN\n'
    exit 1
fi

if [[ -n "$SAFE_PATTERN" ]] && ! grep -q "$SAFE_PATTERN" "$tmp_dir/invariant.log"; then
    printf 'INVARIANT: INCONCLUSIVE\n'
    exit 1
fi

printf 'INVARIANT: HOLDS\n'
