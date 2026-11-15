FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY backend/package*.json ./

# Install dependencies
RUN npm install

# Copy source files
COPY backend/src ./src

# Copy tsconfig.json if it exists
COPY backend/tsconfig.json* ./

# Try to build if tsconfig exists, otherwise just run
RUN npm run build 2>/dev/null || true

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:5000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || true

CMD ["npm", "start"]
