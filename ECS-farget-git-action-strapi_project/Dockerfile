FROM node:20-bullseye AS builder

WORKDIR /app

# Install build tools
RUN apt-get update && apt-get install -y python3 build-essential && rm -rf /var/lib/apt/lists/*

# Copy dependency files and install
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy source and build
COPY . .
RUN mkdir -p ./data
RUN npm run build

# --------------------
FROM node:20-bullseye

WORKDIR /app
COPY --from=builder /app /app

# Ensure data folder exists
RUN mkdir -p ./data

ENV NODE_ENV=production \
    PORT=1337 \
    HOST=0.0.0.0 \
    DATABASE_CLIENT=sqlite \
    DATABASE_FILENAME=./data/data.db \
    APP_KEYS=randomkey123 \
    API_TOKEN_SALT=randomsalt123 \
    ADMIN_JWT_SECRET=adminsecret123

EXPOSE 1337

CMD ["npm", "run", "start"]
