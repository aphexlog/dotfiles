# Aphexlog MCP Server

A general-purpose MCP (Model Context Protocol) server for Amazon Q integration, providing useful tools and resources for development workflow.

## Features

### Tools
- **hello** - Personalized greetings with different styles
- **run_command** - Execute safe shell commands
- **list_directory** - Browse directory contents

### Resources
- **system-info** - Current system and environment information
- **dev-status** - Development environment status (git, directories, etc.)

## Installation

The server uses `uv` for dependency management:

```bash
cd ~/.config/mcp
uv sync
```

## Usage

Run the server:

```bash
cd ~/.config/mcp
uv run python server.py
```

Or use the script entry point:

```bash
uv run aphexlog-mcp-server
```

## Configuration

Add to your Amazon Q CLI configuration to enable this MCP server:

```json
{
  "mcpServers": {
    "aphexlog-general": {
      "command": "uv",
      "args": ["run", "python", "/Users/[username]/.config/mcp/server.py"]
    }
  }
}
```

## Development

The server provides a foundation for adding more tools and resources as needed. Extend by:

1. Adding new tools to `handle_list_tools()`
2. Implementing tool logic in `handle_call_tool()`
3. Adding new resources to `handle_list_resources()`
4. Implementing resource reading in `handle_read_resource()`
