# Stage 1: Build stage using UBI 9
FROM registry.access.redhat.com/ubi9/nodejs-18 AS builder

# Set working directory
WORKDIR /app

# Copy Strapi project only
COPY project/package*.json ./

# Install dependencies as root
RUN npm install

# Copy the rest of the Strapi source
COPY project/ .

# Build the admin panel
RUN npm run build

# -----------------------------------------------------

# Stage 2: Final runtime image
FROM registry.access.redhat.com/ubi9/nodejs-18

# Set working directory
WORKDIR /app

# Copy built app and node_modules from builder
COPY --from=builder /app /app

# Set appropriate ownership and permissions for the app directory
# Fix permissions only after copying files to the runtime image
RUN chown -R 1001:0 /app && chmod -R g+rwX /app

# Ensure node_modules is owned by the correct user (1001)
RUN chown -R 1001:1001 /app/node_modules

# Use OpenShift-compatible non-root user
USER 1001

# Expose port
EXPOSE 1337

# Start the Strapi app
CMD ["npm", "start"]