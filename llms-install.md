# Installing the ChartQuery MCP server

Instructions for AI agents installing this server for a user.

1. Check that Node.js 20 or newer is available (`node --version`).
2. Ask the user for their ChartQuery API key. They can create one at https://app.chartquery.com/register and copy it from https://app.chartquery.com.
   Never print the key back or commit it to a file in a repository.
3. Prefer the hosted server: add it with URL `https://mcp.chartquery.com/` and the header `x-api-key: <key>`:

```json
{
  "mcpServers": {
    "chartquery": {
      "url": "https://mcp.chartquery.com/",
      "headers": {
        "x-api-key": "YOUR_API_KEY"
      }
    }
  }
}
```

Or run it locally over stdio:

```json
{
  "mcpServers": {
    "chartquery": {
      "command": "npx",
      "args": ["-y", "@chartquery/mcp"],
      "env": {
        "CHARTQUERY_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

4. Restart the client and check that the `barcode` tool is listed.

The server needs no other configuration. Each tool call that reaches the API consumes ChartQuery credits.
