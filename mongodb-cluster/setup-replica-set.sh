#!/bin/bash

echo "🚀 Setting up MongoDB Replica Set..."

# Wait for all MongoDB instances to be ready
echo "⏳ Waiting for MongoDB instances to be ready..."

echo "Waiting for primary..."
until mongosh --host mongo-primary:27017 --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo "Still waiting for primary..."
  sleep 3
done

echo "Waiting for secondary1..."
until mongosh --host mongo-secondary1:27017 --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo "Still waiting for secondary1..."
  sleep 3
done

echo "Waiting for secondary2..."
until mongosh --host mongo-secondary2:27017 --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  echo "Still waiting for secondary2..."
  sleep 3
done

echo "✅ All MongoDB instances are ready!"

# Initialize replica set
echo "🔧 Initializing replica set..."
mongosh --host mongo-primary:27017 /scripts/init-replica-set.js

echo "✅ MongoDB Replica Set setup complete!"