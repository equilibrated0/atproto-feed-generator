# Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Enable Corepack for Yarn 4
RUN corepack enable

# Copy package files and Yarn configuration
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install dependencies
RUN yarn install --immutable

# Copy source code
COPY . .

# Build TypeScript
RUN yarn build

# Production stage
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Enable Corepack for Yarn 4
RUN corepack enable

# Copy package files and Yarn configuration
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install production dependencies only
RUN yarn workspaces focus --production

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src ./src

# Create data directory for SQLite database with proper permissions
RUN mkdir -p /app/data && chmod 777 /app/data

# Expose port (adjust if your app uses a different port)
EXPOSE 3000

# Start the application
CMD ["node", "dist/index.js"]
