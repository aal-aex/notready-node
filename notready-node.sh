#!/usr/bin/env bash
# This has only been tested with newer versions of bash & GNU coreutils is assumed available.
set -e

# add -m --model  'model' or 'provider/model'
MODEL="ollama/gemma4:12b"

# 1. Capture Input: Prioritize $1 if given, otherwise read stdin (Heredoc / pipe)
if [ -n "$1" ]; then
  PROMPT_INPUT="$1"
elif [ ! -t 0 ]; then
  PROMPT_INPUT="$(cat)"
else
  echo "Error: No prompt provided to nr-node.sh script." >&2
  exit 1
fi

if [ -z "$PROMPT_INPUT" ]; then
  echo "Error: Empty prompt provided." >&2
  exit 1
fi

# default = 5 min
TIMEOUT_SEC=300

# 2. Execution & Timeout Catch
set +e
timeout $TIMEOUT_SEC crush run -m "$MODEL" -- -y "$PROMPT_INPUT" 2>&1 | sed -ru 's/\x1B\[[0-9;]*[a-zA-Z]//g'
EXIT_CODE=${PIPESTATUS[0]}
set -e

# 3. Graceful Error Handling for agy
if [ "$EXIT_CODE" -eq 124 ]; then
  echo "[Bridge Error] Local Model execution timed out after ${TIMEOUT_SEC} seconds."
  exit 0
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "[Bridge Error] Crush exited with code $EXIT_CODE."
  exit 0
fi

