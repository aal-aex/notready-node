```
                                                   dP          
                                                   88          
88d888b. 88d888b.          88d888b. .d8888b. .d888b88 .d8888b. 
88'  `88 88'  `88 88888888 88'  `88 88'  `88 88'  `88 88ooood8 
88    88 88                88    88 88.  .88 88.  .88 88.  ... 
dP    dP dP                dP    dP `88888P' `88888P8 `88888P' 

--------------------------------------------------------------
NAME         STATUS         ROLES       AGE           VERSION
void-00      NotReady       worker      12812d        v7.2.7
--------------------------------------------------------------
                                                                    
```

# notready-node

Offload multi-step tool calls to a local SLM running in Crush with a skill, instructions, crushrc, and a single shell script.


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
    * Get Crush here: [Crush](https://github.com/charmbracelet/crush/tree/main)
    * Go install: `go install github.com/charmbracelet/crush@latest`
    
> [!NOTE] 
> This has not been well tested, please create an issue if you encounter any non-esoteric bugs. 

## Installation

1. Clone the repo. 
2. Copy `.crushrc.example` to `~/.crushrc` (or `$PWD/.crushrc`) and configure your environment variables. 
3. Ensure `notready-node.sh` is placed somewhere in your `$PATH` and that your primary LLM has access to it.
4. Set up the included `SKILL.md` (`dispatch-daemon`). Please see client-specific instructions for SKILLS. (In `agy-cli`, the directory `dispatch-daemon` is placed at `~/.gemini/config/skills/dispatch-daemon` containing `SKILL.md`).
5. Place DAEMON_SPEC.md in the target directory (~/ or your project).


> [!NOTE]  
> *I have not tested this in any client beyond agy-cli.*

## MCP Servers
Comes with the following MCP Servers tested:

* [mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
* [PagerDuty](https://support.pagerduty.com/main/docs/pagerduty-mcp-server)
    
#### Adding MCP Servers
Append additional MCP servers to .crushrc and update `dispatch-daemon/SKILL.md` with information on the tools it provides.
 
## Environment Variables

### Filtering MCP Tools
Set this environment variable to list tool calls for a specific MCP (you will need new variable for additional filtering this is provided as an example using Atlassian since they have 98 tool calls).

`SLM_ATL_TOOLS`

> *Either set in .crushrc or source.*

### MCP API Keys
This is set-up with 2 MCP's enabled in .crushrc: mcp-atlassian and PagerDuty's mcp (see their repo for recent changes). This is entirely optional. Comment these out in SKILL.md and .crushrc if not in use.

`JIRA_API_TOKEN` - Your Jira/Atlassian API key.

`PAGERDUTY_API_KEY` - Your PagerDuty API key.

`WRK_USER` - The username that precedes your email domain when signing into Jira/Confluence. 

So "your.username"@work.com.

`COMPANY` - The name of your employer. 

So username@"your.employer".com.
