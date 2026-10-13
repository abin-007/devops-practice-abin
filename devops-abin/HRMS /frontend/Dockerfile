# FROM  node:14 as build
# WORKDIR /app
# COPY package*.json ./
# RUN npm install
# COPY . .
# RUN npm run build

# FROM nginx:alpine
# COPY --from=build /app/build /usr/share/nginx/html
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]


# Stage 1: Build React application

FROM node:22-alpine AS build

WORKDIR /app

# Copy dependency definitions first for Docker layer caching
COPY package*.json ./

# Reproducible install based on package-lock.json
RUN npm ci

# Copy application source
COPY . .

# API URL is deliberately relative.
# Works for both CRA and Vite projects.
ARG REACT_APP_API_BASE_URL=/api
ARG VITE_API_BASE_URL=/api

ENV REACT_APP_API_BASE_URL=${REACT_APP_API_BASE_URL}
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

RUN npm run build

# CRA normally creates /app/build
# Vite normally creates /app/dist
RUN mkdir -p /output \
    && if [ -d /app/dist ]; then \
         cp -a /app/dist/. /output/; \
       elif [ -d /app/build ]; then \
         cp -a /app/build/. /output/; \
       else \
         echo "ERROR: Neither dist nor build directory found"; \
         exit 1; \
       fi



# Stage 2: Serve static files

FROM nginxinc/nginx-unprivileged:stable-alpine-slim

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build --chown=nginx:nginx \
     /output/ /usr/share/nginx/html/

EXPOSE 8080

