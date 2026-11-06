# syntax=docker/dockerfile:1

ARG NODE_VERSION=22

FROM node:${NODE_VERSION}-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --ignore-scripts --no-audit --no-fund
COPY tsconfig.json tsconfig.build.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

FROM node:${NODE_VERSION}-alpine AS runtime
LABEL org.opencontainers.image.title="ChartQuery MCP Server" \
      org.opencontainers.image.description="Generate chart images, diagrams, barcodes, QR codes and thermal labels on demand. PNG, SVG or PDF output." \
      org.opencontainers.image.url="https://www.chartquery.com" \
      org.opencontainers.image.source="https://github.com/chartquery/chartquery-mcp" \
      org.opencontainers.image.licenses="MIT"
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist
COPY --chown=node:node package.json LICENSE ./
USER node
ENTRYPOINT ["node", "dist/stdio.js"]
