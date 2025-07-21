#!/usr/bin/env python3
"""
General MCP Server for Amazon Q Integration
Provides useful tools and resources for development workflow
"""

import asyncio
import json
import sys
from typing import Any, Sequence

from mcp.server.models import InitializationOptions
from mcp.server import NotificationOptions, Server
from mcp.server.stdio import stdio_server
from mcp.types import (
    Resource,
    Tool,
    TextContent,
    ImageContent,
    EmbeddedResource,
    LoggingLevel
)
import mcp.types as types

# Initialize the MCP server
server = Server("aphexlog-mcp-server")

@server.list_resources()
async def handle_list_resources() -> list[Resource]:
    """List available resources"""
    return [
        Resource(
            uri="resource://system-info",
            name="System Information",
            description="Current system and environment information",
            mimeType="text/plain",
        ),
        Resource(
            uri="resource://dev-status",
            name="Development Status",
            description="Current development environment status",
            mimeType="application/json",
        ),
    ]

@server.read_resource()
async def handle_read_resource(uri: str) -> str:
    """Read a specific resource"""
    if uri == "resource://system-info":
        import platform
        import os
        
        info = f"""System Information:
- Platform: {platform.system()} {platform.release()}
- Python: {platform.python_version()}
- Architecture: {platform.machine()}
- User: {os.getenv('USER', 'unknown')}
- Home: {os.getenv('HOME', 'unknown')}
- Shell: {os.getenv('SHELL', 'unknown')}
"""
        return info
    
    elif uri == "resource://dev-status":
        import os
        import subprocess
        
        status = {
            "git_status": "unknown",
            "current_directory": os.getcwd(),
            "code_directory_exists": os.path.exists(os.path.expanduser("~/Code")),
            "dotfiles_directory_exists": os.path.exists(os.path.expanduser("~/Code/personal/dotfiles")),
        }
        
        # Try to get git status
        try:
            result = subprocess.run(["git", "status", "--porcelain"], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                status["git_status"] = "clean" if not result.stdout.strip() else "dirty"
            else:
                status["git_status"] = "not_a_repo"
        except:
            status["git_status"] = "error"
        
        return json.dumps(status, indent=2)
    
    else:
        raise ValueError(f"Unknown resource: {uri}")

@server.list_tools()
async def handle_list_tools() -> list[Tool]:
    """List available tools"""
    return [
        Tool(
            name="hello",
            description="Say hello with a personalized message",
            inputSchema={
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Name to greet",
                        "default": "World"
                    },
                    "style": {
                        "type": "string",
                        "enum": ["casual", "formal", "excited"],
                        "description": "Greeting style",
                        "default": "casual"
                    }
                },
            },
        ),
        Tool(
            name="run_command",
            description="Execute a shell command safely (limited to safe commands)",
            inputSchema={
                "type": "object",
                "properties": {
                    "command": {
                        "type": "string",
                        "description": "Command to execute"
                    }
                },
                "required": ["command"],
            },
        ),
        Tool(
            name="list_directory",
            description="List contents of a directory",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Directory path to list",
                        "default": "."
                    },
                    "show_hidden": {
                        "type": "boolean",
                        "description": "Show hidden files",
                        "default": False
                    }
                },
            },
        ),
    ]

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict[str, Any]) -> list[types.TextContent]:
    """Handle tool calls"""
    
    if name == "hello":
        name_arg = arguments.get("name", "World")
        style = arguments.get("style", "casual")
        
        greetings = {
            "casual": f"Hey there, {name_arg}! 👋",
            "formal": f"Good day, {name_arg}. I hope you are well.",
            "excited": f"HELLO {name_arg.upper()}!!! 🎉🚀✨"
        }
        
        message = greetings.get(style, f"Hello, {name_arg}!")
        return [types.TextContent(type="text", text=message)]
    
    elif name == "run_command":
        import subprocess
        import shlex
        
        command = arguments.get("command", "")
        
        # Safety check - only allow certain safe commands
        safe_commands = ["ls", "pwd", "date", "whoami", "uname", "echo", "cat", "head", "tail", "wc"]
        cmd_parts = shlex.split(command)
        
        if not cmd_parts or cmd_parts[0] not in safe_commands:
            return [types.TextContent(
                type="text", 
                text=f"Command '{cmd_parts[0] if cmd_parts else command}' not allowed. Safe commands: {', '.join(safe_commands)}"
            )]
        
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            output = f"Exit code: {result.returncode}\n"
            if result.stdout:
                output += f"STDOUT:\n{result.stdout}"
            if result.stderr:
                output += f"STDERR:\n{result.stderr}"
            return [types.TextContent(type="text", text=output)]
        except subprocess.TimeoutExpired:
            return [types.TextContent(type="text", text="Command timed out")]
        except Exception as e:
            return [types.TextContent(type="text", text=f"Error: {str(e)}")]
    
    elif name == "list_directory":
        import os
        
        path = arguments.get("path", ".")
        show_hidden = arguments.get("show_hidden", False)
        
        try:
            entries = os.listdir(path)
            if not show_hidden:
                entries = [e for e in entries if not e.startswith('.')]
            
            entries.sort()
            
            result = f"Contents of {os.path.abspath(path)}:\n"
            for entry in entries:
                full_path = os.path.join(path, entry)
                if os.path.isdir(full_path):
                    result += f"📁 {entry}/\n"
                else:
                    result += f"📄 {entry}\n"
            
            return [types.TextContent(type="text", text=result)]
        except Exception as e:
            return [types.TextContent(type="text", text=f"Error listing directory: {str(e)}")]
    
    else:
        raise ValueError(f"Unknown tool: {name}")

async def main():
    """Main entry point for the MCP server"""
    # Run the server using stdio transport
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="aphexlog-mcp-server",
                server_version="0.1.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )

if __name__ == "__main__":
    asyncio.run(main())
