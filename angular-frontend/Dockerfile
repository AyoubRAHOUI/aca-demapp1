##################################################
# Multi-stage build for Angular 18 frontend
##################################################

FROM node:22-alpine AS build
WORKDIR /app

# Install build dependencies for native modules
RUN apk add --no-cache python3 make g++

# Copy package files first for better caching
COPY package*.json ./

# Clean install dependencies with optimizations
RUN npm ci --legacy-peer-deps --no-audit --ignore-scripts

# Copy source code
COPY . .

# Build the Angular application for production
RUN npm run build:prod

##################################################
# Production stage with Nginx
##################################################

FROM nginx:1.27-alpine

# Install curl for health check
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -g 1001 -S nginx && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Copy built application from build stage
COPY --from=build /app/dist/angular-frontend/ /usr/share/nginx/html/

# Copy nginx configuration template
COPY default.conf.template /etc/nginx/templates/default.conf.template

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

# Expose port 80
EXPOSE 80

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

##################################################
