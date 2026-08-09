FROM node:22-alpine AS build
WORKDIR /app
RUN corepack enable
COPY . .
RUN pnpm install --frozen-lockfile && pnpm --filter @signaldesk/api build
EXPOSE 8787
CMD ["node", "apps/api/dist/server.js"]
