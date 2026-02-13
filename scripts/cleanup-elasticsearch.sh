#!/bin/bash

# Manual Elasticsearch cleanup script
# Use this for immediate cleanup or emergency disk space recovery

set -e

ELASTICSEARCH_URL="http://localhost:9200"
DAYS_TO_KEEP=${1:-2}

echo "🧹 Elasticsearch Cleanup Script"
echo "================================"
echo "Retention: $DAYS_TO_KEEP days"
echo ""

# Calculate date threshold
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  DATE_THRESHOLD=$(date -u -v-${DAYS_TO_KEEP}d +"%Y.%m.%d")
else
  # Linux
  DATE_THRESHOLD=$(date -u -d "$DAYS_TO_KEEP days ago" +"%Y.%m.%d")
fi

echo "📅 Deleting indices older than: $DATE_THRESHOLD"
echo ""

# Function to delete old indices
delete_old_indices() {
  local pattern=$1
  echo "🔍 Checking $pattern indices..."
  
  # Get all indices matching pattern
  indices=$(curl -s "$ELASTICSEARCH_URL/_cat/indices/$pattern*?h=index" | sort)
  
  if [ -z "$indices" ]; then
    echo "   No indices found matching $pattern"
    return
  fi
  
  deleted_count=0
  for index in $indices; do
    # Extract date from index name (assumes format: pattern-YYYY.MM.DD or pattern-YYYY.MM.DD-*)
    index_date=$(echo "$index" | grep -oE '[0-9]{4}\.[0-9]{2}\.[0-9]{2}' | head -1)
    
    if [ -n "$index_date" ]; then
      if [[ "$index_date" < "$DATE_THRESHOLD" ]]; then
        echo "   🗑️  Deleting: $index (date: $index_date)"
        curl -s -X DELETE "$ELASTICSEARCH_URL/$index" > /dev/null
        ((deleted_count++))
      fi
    fi
  done
  
  if [ $deleted_count -eq 0 ]; then
    echo "   ✅ No old indices to delete"
  else
    echo "   ✅ Deleted $deleted_count indices"
  fi
  echo ""
}

# Delete old indices by pattern
delete_old_indices "filebeat"
delete_old_indices "metricbeat"
delete_old_indices "logs"
delete_old_indices "apm"

# Force merge remaining indices to free up space
echo "🔧 Force merging remaining indices..."
curl -s -X POST "$ELASTICSEARCH_URL/_forcemerge?max_num_segments=1" > /dev/null
echo "✅ Force merge completed"
echo ""

# Show current disk usage
echo "💾 Current Elasticsearch disk usage:"
curl -s "$ELASTICSEARCH_URL/_cat/allocation?v&h=node,disk.used,disk.avail,disk.percent"
echo ""

echo "📊 Current indices:"
curl -s "$ELASTICSEARCH_URL/_cat/indices?v&h=index,docs.count,store.size,creation.date.string" | head -20
echo ""

echo "✅ Cleanup completed!"
