##################################################
# Multi-stage build for Angular 18 frontend
##################################################

FROM node:20.11.1-alpine AS build
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Clean install dependencies (ignore engine warnings)
RUN npm install --legacy-peer-deps --no-audit

# Copy source code
COPY . .

# Build the Angular application
RUN npm run build

##################################################
# Production stage with Nginx
##################################################

FROM nginx:1.25.3-alpine

# Copy built application from build stage
COPY --from=build /app/dist/angular-frontend/ /usr/share/nginx/html/

# Copy nginx configuration template
COPY default.conf.template /etc/nginx/templates/default.conf.template

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

##################################################
