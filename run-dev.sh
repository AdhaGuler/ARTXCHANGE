#!/bin/bash

# ArtXchange Development Server Runner
# This script runs the application in development mode with Firebase disabled

echo "🎨 Starting ArtXchange in Development Mode..."
echo "================================================"

# Set development mode system property
export MAVEN_OPTS="-Dartexchange.dev.mode=true"

# Clean, package, and run with Cargo plugin for Tomcat 10
mvn clean package cargo:run

echo "🚀 ArtXchange should be available at: http://localhost:8080/artexchange"
echo "📱 Note: Firebase authentication is disabled in development mode"
