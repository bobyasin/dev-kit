#!/bin/bash

# Wait for Kibana to be ready
echo "Waiting for Kibana to be ready..."
until curl -s http://localhost:5601/api/status | grep -q "available"; do
  echo "Kibana not ready yet, waiting..."
  sleep 5
done

echo "Kibana is ready! Setting up dark mode..."

# Force dark mode via API
curl -X POST "localhost:5601/api/kibana/settings" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "changes": {
      "theme:darkMode": true,
      "theme:version": "v8",
      "defaultIndex": "filebeat-*",
      "timepicker:timeDefaults": "{ \"from\": \"now-15m\", \"to\": \"now\" }",
      "discover:sampleSize": 1000
    }
  }'

echo ""
echo "Dark mode has been configured!"
echo "Access Kibana at: http://localhost:5601"
echo "If dark mode still doesn't appear, try refreshing the browser or clearing cache."