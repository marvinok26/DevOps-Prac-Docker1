# Use a modern, secure, and smaller Node.js base image
FROM node:18-alpine

# Set maintainer (using new LABEL format)
LABEL maintainer="okongomarvin971@gmail.com"
LABEL description="DevOps Practice Docker Container"
LABEL version="1.0"

# Create app directory
WORKDIR /usr/src/app

# Copy package files first (better Docker layer caching)
COPY package*.json ./

# Install dependencies (production only for smaller image)
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application source code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs && \
    chown -R nodejs:nodejs /usr/src/app

# Switch to non-root user
USER nodejs

# Health check with curl (install curl first)
USER root
RUN apk add --no-cache curl
USER nodejs

HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=5s \
            --retries=3 \
            CMD curl -f http://localhost:8000 || exit 1

# Expose port
EXPOSE 8000

# Start the application
CMD ["node", "server.js"]