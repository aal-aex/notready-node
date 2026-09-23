#!/usr/bin/env bash
# This has only been tested with newer versions of bash & GNU coreutils is assumed available.
# Pathing logic and Code Review provided by ✦︎ Gemini 3.6 Flash.
set -e

#MODEL=$YOUR_SLM_MODEL_HERE
MODEL=ollama/gemma4:12b

# Checks & Environment resolution
command -v crush >/dev/null 2>&1 || { echo "Error: crush binary not found in PATH." >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC="DAEMON_SPEC.md" # local project override

if [[ ! -f "$SPEC" ]]; then
  SPEC="${SCRIPT_DIR}/DAEMON_SPEC.md" # global fallback
fi

if [[ ! -f "$SPEC" ]]; then
  echo "Error: DAEMON_SPEC.md not found in \$PWD or $SCRIPT_DIR." >&2
  exit 1
fi

# 1. Capture Input: Prioritize $1 if given, otherwise read stdin (Heredoc / pipe)
if [ -n "$1" ]; then
  PROMPT_INPUT="$1"
elif [ ! -t 0 ]; then
  PROMPT_INPUT="$(cat)"
else
  echo "Error: No prompt provided to notready-node.sh script." >&2
  exit 1
fi

if [ -z "$PROMPT_INPUT" ]; then
  echo "Error: Empty prompt provided." >&2
  exit 1
fi

# default = 300 sec
TIMEOUT_SEC=300

# 2. Execution & Timeout Catch
set +e

# Headless permissions are handled natively via 'permissions allow ...' in ~/.crushrc.
timeout --kill-after=10s $TIMEOUT_SEC crush run --quiet -m "$MODEL" -- "$(cat "$SPEC") Request: $PROMPT_INPUT" 2>&1
EXIT_CODE=$?
set -e

# 3. Graceful Error Handling for agy
if [ "$EXIT_CODE" -eq 124 ] || [ "$EXIT_CODE" -eq 137 ]; then
  echo "[Bridge Error] Local Model execution timed out after ${TIMEOUT_SEC} seconds."
  exit 0
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "[Bridge Error] Crush exited with code $EXIT_CODE."
  exit "$EXIT_CODE"
fi
