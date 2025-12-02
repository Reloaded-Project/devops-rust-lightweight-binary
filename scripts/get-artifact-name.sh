#!/usr/bin/env bash
# Generates artifact names for Rust builds.
# Usage: ./get-artifact-name.sh --target <target> --artifact-type <type> [--artifact-prefix <prefix>] [--crate-name <name>] [--features <features>] [--use-friendly-target-names <true|false>] [--exclude-features <features>]
# Outputs the artifact name to stdout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
ARTIFACT_PREFIX=""
CRATE_NAME=""
TARGET=""
FEATURES=""
USE_FRIENDLY_TARGET_NAMES="true"
ARTIFACT_TYPE=""
EXCLUDE_FEATURES=""

# Parse named parameters
while [[ $# -gt 0 ]]; do
  case $1 in
    --artifact-prefix)
      ARTIFACT_PREFIX="$2"
      shift 2
      ;;
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
    --exclude-features)
      EXCLUDE_FEATURES="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1" >&2
      exit 1
      ;;
  esac
done

# Validate required parameters
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

# Filter features by excluding specified features from the list
# Args: $1 = features string (comma-separated), $2 = exclude list (comma-separated)
# Returns: filtered features (comma-separated) or empty string
filter_features() {
  local features="$1"
  local exclude_list="$2"

  # If no features or no exclude list, return features as-is
  if [[ -z "$features" ]] || [[ -z "$exclude_list" ]]; then
    echo "$features"
    return
  fi

  # Build associative array of features to exclude (with whitespace trimming)
  declare -A exclude_map
  IFS=',' read -ra exclude_array <<< "$exclude_list"
  for item in "${exclude_array[@]}"; do
    # Trim leading/trailing whitespace
    trimmed=$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ -n "$trimmed" ]]; then
      exclude_map["$trimmed"]=1
    fi
  done

  # Filter features, keeping only those not in exclude list
  local result=()
  IFS=',' read -ra features_array <<< "$features"
  for feature in "${features_array[@]}"; do
    # Trim leading/trailing whitespace
    trimmed=$(echo "$feature" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ -n "$trimmed" ]] && [[ -z "${exclude_map[$trimmed]:-}" ]]; then
      result+=("$trimmed")
    fi
  done

  # Join result with commas
  local IFS=','
  echo "${result[*]}"
}

# Generate feature suffix: -features if set, empty if not
# Apply exclusion filter before generating suffix
FILTERED_FEATURES=$(filter_features "$FEATURES" "$EXCLUDE_FEATURES")
if [[ -n "$FILTERED_FEATURES" ]]; then
  FEATURE_SUFFIX="-$FILTERED_FEATURES"
else
  FEATURE_SUFFIX=""
fi

# Determine artifact prefix based on precedence:
# 1. If artifact-prefix is non-empty, use it
# 2. Else if crate-name is set, use legacy logic (crate-name for binary, C-Library-crate-name for library)
# 3. Else no prefix (just target[-features])
generate_prefix() {
  local artifact_type="$1"
  if [[ -n "$ARTIFACT_PREFIX" ]]; then
    echo "${ARTIFACT_PREFIX}-"
  elif [[ -n "$CRATE_NAME" ]]; then
    # Legacy behaviour
    case "$artifact_type" in
      binary|binary-symbols)
        echo "${CRATE_NAME}-"
        ;;
      library|library-symbols)
        echo "C-Library-${CRATE_NAME}-"
        ;;
    esac
  else
    echo ""
  fi
}

# Generate artifact name based on type
PREFIX=$(generate_prefix "$ARTIFACT_TYPE")
case "$ARTIFACT_TYPE" in
  binary)
    echo "${PREFIX}${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}"
    ;;
  binary-symbols)
    echo "${PREFIX}${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}.symbols"
    ;;
  library)
    echo "${PREFIX}${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}"
    ;;
  library-symbols)
    echo "${PREFIX}${TARGET_FOR_ARTIFACT}${FEATURE_SUFFIX}.symbols"
    ;;
esac
