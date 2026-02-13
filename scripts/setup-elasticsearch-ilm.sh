#!/bin/bash

# Setup Elasticsearch Index Lifecycle Management (ILM) Policies
# This script configures automatic data retention and cleanup

set -e

ELASTICSEARCH_URL="http://localhost:9200"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔧 Setting up Elasticsearch ILM policies..."

# Wait for Elasticsearch to be ready
echo "⏳ Waiting for Elasticsearch to be ready..."
until curl -s "$ELASTICSEARCH_URL/_cluster/health" > /dev/null; do
  echo "   Waiting for Elasticsearch..."
  sleep 5
done
echo "✅ Elasticsearch is ready"

# Create logs lifecycle policy
echo "📋 Creating logs lifecycle policy (30 days retention)..."
curl -X PUT "$ELASTICSEARCH_URL/_ilm/policy/logs-policy" \
  -H 'Content-Type: application/json' \
  -d @"$PROJECT_ROOT/elasticsearch/ilm-policies/logs-lifecycle-policy.json"
echo ""

# Create metrics lifecycle policy
echo "📋 Creating metrics lifecycle policy (14 days retention)..."
curl -X PUT "$ELASTICSEARCH_URL/_ilm/policy/metrics-policy" \
  -H 'Content-Type: application/json' \
  -d @"$PROJECT_ROOT/elasticsearch/ilm-policies/metrics-lifecycle-policy.json"
echo ""

# Apply template for logs indices
echo "📋 Applying index template for logs-*..."
curl -X PUT "$ELASTICSEARCH_URL/_index_template/logs-template" \
  -H 'Content-Type: application/json' \
  -d @"$PROJECT_ROOT/elasticsearch/index-templates/logs-template.json"
echo ""

# Create initial logs index with alias
echo "📋 Creating initial logs index..."
curl -X PUT "$ELASTICSEARCH_URL/logs-000001" \
  -H 'Content-Type: application/json' \
  -d '{
  "aliases": {
    "logs": {
      "is_write_index": true
    }
  }
}'
echo ""

echo "✅ ILM policies configured successfully!"
echo ""
echo "📊 Policy Summary:"
echo "   - Logs: Deleted after 2 days"
echo "   - Metrics: Deleted after 2 days"
echo "   - Rollover: Every 1 day or 10GB"
echo ""
echo "🔍 Check policy status:"
echo "   curl $ELASTICSEARCH_URL/_ilm/policy"
echo ""
echo "📈 Check index status:"
echo "   curl $ELASTICSEARCH_URL/_cat/indices?v"
