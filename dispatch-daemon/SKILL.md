---
name: dispatch-daemon
description: Routes offline codebase modifications, Jira/Confluence operations, GitHub PRs, Slack alerts, and PagerDuty tasks to the local SLM agent running in Crush (Charmbracelet).
---

# Skill: dispatch-daemon
Invoke `notready-node.sh` whenever an action requires multiple steps to execute to quickly dispatch a local SLM and bypass multi-step tooling loops. 

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
