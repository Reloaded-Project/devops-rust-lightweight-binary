#!/usr/bin/env bash
# Generates artifact names for Rust builds.
# Usage: ./get-artifact-name.sh --crate-name <name> --target <target> --artifact-type <type> [--features <features>] [--use-friendly-target-names <true|false>]
# Outputs the artifact name to stdout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
CRATE_NAME=""
TARGET=""
FEATURES=""
USE_FRIENDLY_TARGET_NAMES="true"
ARTIFACT_TYPE=""

# Parse named parameters
while [[ $# -gt 0 ]]; do
  case $1 in
    --crate-name)
      CRATE_NAME="$2"
      shift 2
      ;;
    --target)
      TARGET="$2"
      shift 2
      ;;
    --features)
      FEATURES="$2"
      shift 2
      ;;
    --use-friendly-target-names)
      USE_FRIENDLY_TARGET_NAMES="$2"
      shift 2
      ;;
    --artifact-type)
      ARTIFACT_TYPE="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1" >&2
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$CRATE_NAME" ]]; then
  echo "Error: --crate-name is required" >&2
  exit 1
fi

if [[ -z "$TARGET" ]]; then
  echo "Error: --target is required" >&2
  exit 1
fi

if [[ -z "$ARTIFACT_TYPE" ]]; then
  echo "Error: --artifact-type is required (binary|binary-symbols|library|library-symbols)" >&2
  exit 1
fi

# Validate artifact-type
case "$ARTIFACT_TYPE" in
  binary|binary-symbols|library|library-symbols)
    ;;
  *)
    echo "Error: --artifact-type must be one of: binary, binary-symbols, library, library-symbols" >&2
    exit 1
    ;;
esac

# Resolve target name for artifact (friendly or raw)
if [[ "$USE_FRIENDLY_TARGET_NAMES" == "true" ]]; then
  TARGET_FOR_ARTIFACT=$("$SCRIPT_DIR/get-friendly-target-name.sh" "$TARGET")
else
  TARGET_FOR_ARTIFACT="$TARGET"
fi

# Generate feature suffix: -features if set, empty if not
if [[ -n "$FEATURES" ]]; then
  FEATURE_SUFFIX="-$FEATURES"
else
  FEATURE_SUFFIX=""
fi

# Generate artifact name based on type
case "$ARTIFACT_TYPE" in
  binary)
    echo "${CRATE_NAME}-${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}"
    ;;
  binary-symbols)
    echo "${CRATE_NAME}-${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}.symbols"
    ;;
  library)
    echo "C-Library-${CRATE_NAME}-${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}"
    ;;
  library-symbols)
    echo "C-Library-${CRATE_NAME}-${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}.symbols"
    ;;
esac
