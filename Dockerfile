# Stage 1: Build stage using UBI 9
FROM registry.access.redhat.com/ubi9/nodejs-18 AS builder

# Set working directory
WORKDIR /opt/app

# Copy Strapi project only
COPY project/package*.json ./

# Fix permissions before npm install (so npm has access to install dependencies)
RUN chmod -R 755 /opt/app && chown -R 1001:0 /opt/app

RUN npm install

# Copy rest of the Strapi source
COPY project/ .

# Build the admin panel
RUN npm run build

# -----------------------------------------------------

# Stage 2: Final runtime image
FROM registry.access.redhat.com/ubi9/nodejs-18

# Set working directory
WORKDIR /opt/app

# Copy built app and node_modules from builder
COPY --from=builder /opt/app /opt/app

# OpenShift-safe permissions
RUN chown -R 1001:0 /opt/app && chmod -R g+rwX /opt/app

# Use OpenShift-compatible non-root user
USER 1001

# Expose port
EXPOSE 1337

# Start the Strapi app
CMD ["npm", "start"]