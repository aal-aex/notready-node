
# notready-node

Offload multi-step tool calls to a local SLM running in Crush with a skill, config file, and a single shell script.


## Usage/Examples

**positional arguments**

`notready-node.sh "look up SPC-1234 using mcp-atlassian"`

**heredoc/pipe**

```bash
cat <<'EOF' | notready-node.sh
Look up pages 12345, 6789, and 113910 in Confluence.
For each: GET current parentId and version via /wiki/api/v2/pages/{id}.
Then move each to parentId 1239495 (02. SLAs) using PUT.
Increment version by 1. Report success/failure per page ID.
EOF
```


## Dependencies

**Requires:**
1. Either Linux or MacOS.
2. **macOS Users:** Homebrew with GNU coreutils (`brew install coreutils gnu-sed gnu-tar findutils grep gawk`) and a newer version of bash installed.
3. Local SLM already installed and set up in Ollama. 
    * The default model set is `gemma4:12b` but this can be modified in `.crushrc` and the script allows setting the local SLM.
4. Crush installed alongside another LLM/AI coding interface (tested with `agy-cli`).

> [!NOTE] 
> This has not been well tested, please create an issue if you encounter non-esoteric bugs. 

## Installation

1. Clone the repo. 
2. Copy `.crushrc.example` to `~/.crushrc` (or `$PWD/.crushrc`) and configure your environment variables. 
3. Ensure `notready-node.sh` is placed somewhere in your `$PATH` and that your primary LLM has access to it.
4. Setting up the included `SKILL.md` (`liminal-loop`). Please see client-specific instructions for SKILLS. (In `agy-cli`, the directory `liminal-loop` is placed at `~/.gemini/config/skills/liminal-loop` containing `SKILL.md`). 


> [!NOTE]  
> *I have not tested this in any client beyond agy-cli.*
    
#### Adding MCP Servers
Append additional MCP servers to .crushrc and update `liminal-loop/SKILL.md` with information on the tools it provides. 
## Environment Variables

### Filtering MCP Tools
Set this environment variable to list tool calls for a specific MCP (you will need new variable for additional filtering this is provided as an example using Atlassian since they have 98 tool calls).

`SLM_ATL_TOOLS`

> *Either set in .crushrc or source.*

### MCP API Keys
This is set-up with 2 MCP's enabled in .crushrc: mcp-atlassian and PagerDuty's mcp (see their repo for recent changes). This is entirely optional. Comment these out in SKILL.md and .crushrc if not in use.

`JIRA_API_KEY` - Your Jira/Atlassian API key.

`PAGERDUTY_API_KEY` - Your PagerDuty API key.

`WRK_USER` - The username that precedes your email domain when signing into Jira/Confluence. 

So "your.username"@work.com.

`COMPANY` - The name of your employer. 

So username@"your.employer".com.
