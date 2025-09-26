
FROM node:20-bullseye AS builder

WORKDIR /app

# Install required build tools (only for build stage)
RUN apt-get update && apt-get install -y python3 build-essential && rm -rf /var/lib/apt/lists/*

# Copy dependency files first (for better caching)
COPY package*.json ./

# Install dependencies (include dev for build step)
RUN npm install --legacy-peer-deps

# Copy full source
COPY . .

# Build Strapi admin panel
RUN npm run build

#-----------------------------------------------------------------
FROM node:20-bullseye

WORKDIR /app

# Copy only the built app (with node_modules) from builder
COPY --from=builder /app /app

# Set environment variables
ENV NODE_ENV=production \
    PORT=1337 \
    HOST=0.0.0.0

EXPOSE 1337

# Start Strapi in production mode
CMD ["npm", "run", "start"]
