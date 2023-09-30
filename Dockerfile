FROM node:18-alpine AS dependencies
ENV NODE_ENV=production
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:18-alpine AS builder
ENV NODE_ENV=development
WORKDIR /app
COPY . .
RUN npm ci && NODE_ENV=production npm run build

FROM node:18-alpine AS production
WORKDIR /app
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package*.json ./
COPY --from=dependencies /app/node_modules ./node_modules

EXPOSE 4000

CMD ["node_modules/.bin/next", "start"]