---
name: liminal-loop
description: Routes offline codebase modifications, Jira/Confluence operations, GitHub PRs, Slack alerts, and PagerDuty tasks to the local SLM agent running in Crush (Charmbracelet).
---

# Skill: Liminal Loop

**Short lookups — positional arg still works**
notready-node.sh "look up the jira issue SPC-1234"

**Complex ops — heredoc via pipe, no escaping**
cat <<'EOF' | notready-node.sh
Look up pages 12345, 6789, and 113910 in Confluence.
For each: GET current parentId and version via /wiki/api/v2/pages/{id}.
Then move each to parentId 1239495 (02. SLAs) using PUT.
Increment version by 1. Report success/failure per page ID.
EOF

## Context
Activate this skill whenever a request requires more than one turn to execute.
**Examples:**
1. Editing a file (often requires read + edit)
2. MCP tool calls
3. Scripting + testing.

## Query Formatting
When invoking `notready-node.sh`, avoid open-ended or ambiguous requests. 
For multi-step tasks always compile the request into a deterministic instruction block formatted like this:

Task: <High-level objective>
Steps to execute:
1. Query <Jira/Confluence/PagerDuty/File> to retrieve <data>.
2. Based on the retrieved data, execute <action/edit/search>.
3. If <error condition>, fallback to <alternative action>.
4. Return a structured markdown summary containing:
   - Status / Outcome
   - Key findings or modified files
   - Any unblocked next steps
  

## `notready-node.sh` Contents

```bash
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

```


## Available Downstream Capabilities (SLM Runs the Liminal Loop)
When invoking `notready-node.sh`, a local SLM  handles execution natively via the following local MCP tools:

| Platform | MCP Tools & Capabilities |
| :--- | :--- |
| **Filesystem & Shell** | View, edit, create files, grep codebase, run local test/build scripts. |
| **Atlassian** | `mcp-atlassian` — Query Jira issues /  Confluence pages / Users |
| **PagerDuty** | Trigger incidents, inspect active on-call logs, acknowledge/resolve alerts. |


> Additional MCP Servers ---------------------------------------`✄ 
Any user added MCP servers belong below:
> <!-- | **GitHub** | Create pull requests, list active branches, inspect code diffs, fetch issues. | -->
> <!-- | **Slack** | Search channel history, send team updates, post incident summaries. | -->
