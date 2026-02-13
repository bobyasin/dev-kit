# Elasticsearch Data Retention & Cleanup

This configuration implements automatic data lifecycle management to prevent disk space issues.

## Automatic Cleanup (ILM Policies)

### Logs Policy (2 days retention)

- **Hot phase**: Rollover after 1 day or 10GB
- **Delete phase**: After 2 days, automatically delete

### Metrics Policy (2 days retention)

- **Hot phase**: Rollover after 1 day or 10GB
- **Delete phase**: After 2 days, automatically delete

## Setup Instructions

### 1. Start Elasticsearch

```bash
docker-compose up -d elasticsearch kibana
```

### 2. Apply ILM Policies

```bash
chmod +x scripts/setup-elasticsearch-ilm.sh
./scripts/setup-elasticsearch-ilm.sh
```

This will:

- Create lifecycle policies for logs and metrics
- Apply index templates
- Set up automatic rollover

### 3. Verify Setup

```bash
# Check ILM policies
curl http://localhost:9200/_ilm/policy?pretty

# Check indices
curl http://localhost:9200/_cat/indices?v

# Check disk usage
curl http://localhost:9200/_cat/allocation?v
```

## Manual Cleanup

If you need immediate cleanup:

```bash
# Delete indices older than 2 days (default)
chmod +x scripts/cleanup-elasticsearch.sh
./scripts/cleanup-elasticsearch.sh 2

# Delete indices older than 1 day
./scripts/cleanup-elasticsearch.sh 1

# Delete all indices (emergency cleanup)
./scripts/cleanup-elasticsearch.sh 0
```

## Disk Space Thresholds

Configured in docker-compose.yml:

- **Low watermark (85%)**: No new shards allocated to node
- **High watermark (90%)**: Elasticsearch tries to relocate shards
- **Flood stage (95%)**: Indices become read-only

## Monitoring Disk Usage

### Check current usage:

```bash
curl http://localhost:9200/_cat/allocation?v&h=node,disk.used,disk.avail,disk.percent
```

### Check index sizes:

```bash
curl http://localhost:9200/_cat/indices?v&s=store.size:desc
```

### Check ILM status:

```bash
curl http://localhost:9200/_ilm/status?pretty
```

## Optimization Settings

Applied in index templates:

- **best_compression**: Reduces storage by ~30-40%
- **refresh_interval: 30s**: Reduces indexing overhead
- **number_of_replicas: 0**: No replicas for dev environment
- **number_of_shards: 1**: Optimal for small datasets

## Troubleshooting

### Indices are read-only

If disk reaches flood stage (95%), indices become read-only:

```bash
# Free up space first, then:
curl -X PUT "http://localhost:9200/_all/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index.blocks.read_only_allow_delete": null}'
```

### Force delete specific index

```bash
curl -X DELETE "http://localhost:9200/filebeat-2024.01.01"
```

### Disable ILM temporarily

```bash
curl -X POST "http://localhost:9200/_ilm/stop"
```

### Re-enable ILM

```bash
curl -X POST "http://localhost:9200/_ilm/start"
```

## Customization

To adjust retention periods, edit:

- `elasticsearch/ilm-policies/logs-lifecycle-policy.json` (change "2d" to your preference)
- `elasticsearch/ilm-policies/metrics-lifecycle-policy.json` (change "2d" to your preference)

Then reapply:

```bash
./scripts/setup-elasticsearch-ilm.sh
```
