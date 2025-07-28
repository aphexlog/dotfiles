#!/usr/bin/env python3
"""
Simple stock price MCP server implementation.
"""

import asyncio
import random
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import logging
import sys

# Set up logging to stderr so it doesn't interfere with MCP protocol
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)

# Create server instance
server = Server("stock-server")

# Mock stock data
STOCK_DATA = {
    "AAPL": {"name": "Apple Inc.", "base_price": 175.00},
    "GOOGL": {"name": "Alphabet Inc.", "base_price": 140.00},
    "MSFT": {"name": "Microsoft Corporation", "base_price": 420.00},
    "AMZN": {"name": "Amazon.com Inc.", "base_price": 155.00},
    "TSLA": {"name": "Tesla Inc.", "base_price": 250.00},
    "NVDA": {"name": "NVIDIA Corporation", "base_price": 875.00},
    "META": {"name": "Meta Platforms Inc.", "base_price": 485.00},
}


@server.list_tools()
async def list_tools() -> list[Tool]:
    """List available tools."""
    return [
        Tool(
            name="get_stock_price",
            description="Get the current stock price for a given symbol",
            inputSchema={
                "type": "object",
                "properties": {
                    "symbol": {
                        "type": "string",
                        "description": "Stock symbol (e.g., AAPL, GOOGL, MSFT)",
                    }
                },
                "required": ["symbol"],
            },
        ),
        Tool(
            name="list_stocks",
            description="List all available stock symbols",
            inputSchema={"type": "object", "properties": {}},
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """Handle tool calls."""
    if name == "get_stock_price":
        symbol = arguments.get("symbol", "").upper()
        if symbol in STOCK_DATA:
            stock = STOCK_DATA[symbol]
            # Generate a mock price with some variation
            variation = random.uniform(-0.05, 0.05)  # ±5% variation
            current_price = stock["base_price"] * (1 + variation)
            change = current_price - stock["base_price"]
            change_percent = (change / stock["base_price"]) * 100

            result = f"""
Stock: {stock["name"]} ({symbol})
Current Price: ${current_price:.2f}
Change: ${change:+.2f} ({change_percent:+.2f}%)
            """.strip()

            return [TextContent(type="text", text=result)]
        else:
            available = ", ".join(STOCK_DATA.keys())
            return [
                TextContent(
                    type="text",
                    text=f"Stock symbol '{symbol}' not found. Available symbols: {available}",
                )
            ]

    elif name == "list_stocks":
        stocks_list = []
        for symbol, data in STOCK_DATA.items():
            stocks_list.append(f"{symbol}: {data['name']}")

        result = "Available stocks:\n" + "\n".join(stocks_list)
        return [TextContent(type="text", text=result)]

    else:
        raise ValueError(f"Unknown tool: {name}")


async def main():
    """Run the MCP server."""
    logger.info("Starting stock MCP server...")
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream, write_stream, server.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())
