# Étape 1 : build avec les dépendances de dev pour les tests
FROM node:25-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY src/ ./src/

# Étape 2 : image de production minimale
FROM node:25-alpine AS production
WORKDIR /app

# Créer un utilisateur non-root dédié
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/src ./src

USER appuser

EXPOSE 3001
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:3001/api/health || exit 1

CMD ["node", "src/index.js"]
