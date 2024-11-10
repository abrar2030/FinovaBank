#!/bin/bash

# Install dependencies
echo "Installing frontend dependencies..."
npm install

# Build the frontend for production
echo "Building the frontend..."
npm run build

# Start the frontend in development mode
echo "Starting the frontend..."
npm start

