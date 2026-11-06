# ChartQuery MCP Server

Official [Model Context Protocol](https://modelcontextprotocol.io) server for the [ChartQuery](https://www.chartquery.com) chart and QR code API.

Generate chart images, diagrams, barcodes, QR codes and thermal labels on demand. PNG, SVG or PDF output.

It lets Claude, Cursor, VS Code, Windsurf and any MCP client call the API as tools. Runs over **stdio** (local) or **Streamable HTTP** (self-hosted).

## Requirements

- Node.js 20 or newer
- a ChartQuery API key — [sign up](https://app.chartquery.com/register), then copy it from the [dashboard](https://app.chartquery.com)

## Hosted server (recommended)

ChartQuery runs this server for you at **`https://mcp.chartquery.com/`** (Streamable HTTP). Send your API key in the `x-api-key` header; nothing to install.

```sh
claude mcp add --transport http chartquery https://mcp.chartquery.com/ --header "x-api-key: YOUR_API_KEY"
```

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

The hosted server and this package expose the same API; run the package locally when you want stdio, your own network egress, or to self-host it.

## Run it locally

### Claude Code

```sh
claude mcp add chartquery --env CHARTQUERY_API_KEY=YOUR_API_KEY -- npx -y @chartquery/mcp
```

### Claude Desktop, Cursor, Windsurf and other clients

Add the server to the client's MCP configuration (`claude_desktop_config.json`, `.cursor/mcp.json`…):

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

### VS Code

```json
{
  "servers": {
    "chartquery": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@chartquery/mcp"],
      "env": {
        "CHARTQUERY_API_KEY": "${input:chartquery-api-key}"
      }
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "chartquery-api-key",
      "description": "ChartQuery API key",
      "password": true
    }
  ]
}
```

### Claude Desktop extension

Download the `.mcpb` bundle from the releases page and open it; Claude Desktop asks for your API key.

### Docker

```sh
docker build -t chartquery-mcp .
docker run -i --rm -e CHARTQUERY_API_KEY=YOUR_API_KEY chartquery-mcp
```

## Tools

| Tool             | Description                                                                                                                                                                                              |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `barcode`        | Generate a barcode image via GET. Output: SVG (default) or PNG. Supports 25+ formats: EAN-13, Code 128, ITF-14, GS1-128, postal codes and more.                                                          |
| `chart`          | Render a Chart.js image via GET. Pass the full chart object as URL-encoded JSON in query. Prefer format png for ChatGPT. POST sends the same object as a JSON body, not query.                           |
| `chart_ai`       | Describe a chart in plain English via GET and get a rendered image back. Powered by AI.                                                                                                                  |
| `chart_render`   | Render a previously saved chart by ID. Public, no API key required. Supports URL overrides for templates (?data1=, ?labels=, ?title=…).                                                                  |
| `chart_view`     | View a previously saved chart as an interactive HTML page. Public, no API key required. Iframe-embeddable.                                                                                               |
| `diagram`        | Render a diagram via GET. Use type (mermaid, d2, …), query (source code), and format=png for ChatGPT. POST uses diagram_type and diagram_source instead.                                                 |
| `diagram_ai`     | Describe a diagram in plain English via GET and get a rendered image back. Powered by AI.                                                                                                                |
| `diagram_render` | Render a previously saved diagram by ID. Public, no API key required. Supports ?format= and ?query= overrides.                                                                                           |
| `diagram_view`   | View a previously saved diagram as an HTML page. Public, no API key required. Iframe-embeddable with inline SVG rendering.                                                                               |
| `label`          | Preview a thermal label via GET. Pass the same label object as a URL-encoded JSON string in query. Inside that JSON, text items use content and size (1-10), not text or fontSize. Prefer format=png fo… |
| `label_compile`  | Compile a label to printer commands (tsc, zpl, epl, …). POST width, language, and elements. Text uses content and size (1-10), not text or fontSize. No barcode element. Example: {"width":40,"height":… |
| `label_convert`  | Convert printer commands from one language to another. POST source, from, and to. from is the source language (tsc, zpl, epl, …). to is the target (tsc, zpl, escpos, …).                                |
| `label_parse`    | Parse printer commands into structured elements. POST source and language (tsc, zpl, epl, …).                                                                                                            |
| `label_render`   | Render a previously saved label by ID. Public, no API key required. Supports ?format= override.                                                                                                          |
| `label_validate` | Validate printer commands. POST source (the raw commands) and language (tsc, zpl, epl, …).                                                                                                               |
| `label_view`     | View a previously saved label as an HTML page. Public, no API key required. Iframe-embeddable with inline SVG rendering.                                                                                 |
| `qrcode`         | Generate a styled QR code via GET. Output: SVG (default) or PNG. Supports dot styles, gradients, custom corners and all QR versions.                                                                     |
| `stats`          | Infrastructure health for an engine or endpoint over the last hour. Not scoped to your account or tenant. Enabled per account: HTTP 403 means contact support to activate it.                            |
| `usage`          | Return this account's Chartquery usage and credit balance. No body. Requires an API key.                                                                                                                 |

Every tool that calls the API consumes credits. JSON results are returned as text; images are returned inline and other files (PDF…) as embedded resources, up to 4 MB.

## Streamable HTTP

```sh
npx @chartquery/mcp --http --port 3000
```

The endpoint is `POST /mcp` (stateless, JSON responses). Each client sends its own key in the `x-api-key` header (or `Authorization: Bearer <key>`); the server never uses a key of its own. It binds to `127.0.0.1` by default and rejects browser origins unless you allow them — put it behind TLS before exposing it.

`createHttpHandler()` is exported for Fetch-compatible runtimes (Cloudflare Workers, Deno, Bun):

```ts
import { createHttpHandler } from "@chartquery/mcp";

export default { fetch: createHttpHandler({ allowedOrigins: [] }) };
```

## Security

- The API key is read from `CHARTQUERY_API_KEY` (stdio) or the request headers (HTTP) and removed from error messages.
- Content fetched from websites is untrusted: the server instructions tell the model to treat it as data, not instructions.
- See [SECURITY.md](SECURITY.md) to report a vulnerability.

## Development

```sh
npm install
npm test
npm run build
npx @modelcontextprotocol/inspector node dist/stdio.js
```

## Built on the SDK

The server uses the official [Node.js SDK](https://github.com/chartquery/chartquery-node) (`@chartquery/sdk`).

## All ChartQuery SDKs

| SDK        | Package                                                                   | Install                                      |
| ---------- | ------------------------------------------------------------------------- | -------------------------------------------- |
| Node.js    | [`@chartquery/sdk`](https://www.npmjs.com/package/@chartquery/sdk)        | `npm install @chartquery/sdk`                |
| Python     | [`chartquery`](https://pypi.org/project/chartquery/)                      | `pip install chartquery`                     |
| Go         | [`chartquery-go`](https://pkg.go.dev/github.com/chartquery/chartquery-go) | `go get github.com/chartquery/chartquery-go` |
| .NET       | [`ChartQuery`](https://www.nuget.org/packages/ChartQuery)                 | `dotnet add package ChartQuery`              |
| Ruby       | [`chartquery`](https://rubygems.org/gems/chartquery)                      | `gem install chartquery`                     |
| PHP        | [`chartquery/sdk`](https://packagist.org/packages/chartquery/sdk)         | `composer require chartquery/sdk`            |
| Java       | [`chartquery-java`](https://github.com/chartquery/chartquery-java)        | build from source, see its README            |
| CLI        | [`@chartquery/cli`](https://www.npmjs.com/package/@chartquery/cli)        | `npm install -g @chartquery/cli`             |
| MCP server | [`@chartquery/mcp`](https://www.npmjs.com/package/@chartquery/mcp)        | `npx -y @chartquery/mcp`                     |

## License

MIT — see [LICENSE](LICENSE).
