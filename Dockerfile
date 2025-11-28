# --- Stage 1: Build ---
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
# Gunakan 'npm ci' jika ada package-lock.json agar versi install konsisten
RUN npm install

# Copy seluruh source code
COPY . .

# Build Nuxt untuk production
# Ini akan menghasilkan folder .output yang standalone (tidak butuh node_modules lagi)
RUN npm run build

# --- Stage 2: Production Image ---
FROM node:20-alpine

WORKDIR /app

# Copy hasil build dari Stage 1
# Kita hanya butuh folder .output, tidak perlu source code atau node_modules yang berat
COPY --from=builder /app/.output ./.output

# Set Environment Variables agar bisa diakses dari luar container
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

# Expose port
EXPOSE 3000

# Jalankan server Nuxt
CMD ["node", ".output/server/index.mjs"]
