# Elasticsearch Disk Space Management - Quick Start

## What Changed

Your Elasticsearch setup now includes automatic data cleanup to prevent disk space issues:

### ✅ Automatic Features

1. **Index Lifecycle Management (ILM)** - Auto-deletes old data
2. **Disk watermark thresholds** - Prevents disk from filling up
3. **Data compression** - Reduces storage by 30-40%
4. **Automatic rollover** - Splits large indices

### 📊 Retention Policies

- **Logs (filebeat, logs-\*)**: 2 days retention
- **Metrics (metricbeat, metrics-\*)**: 2 days retention

## Quick Setup (3 Steps)

### 1. Restart Elasticsearch with new settings

```bash
docker-compose up -d elasticsearch
```

### 2. Apply ILM policies (one-time setup)

```bash
./scripts/setup-elasticsearch-ilm.sh
```

### 3. Verify it's working

```bash
curl http://localhost:9200/_ilm/policy?pretty
```

## Manual Cleanup (If Needed Now)

If your disk is already full, run immediate cleanup:

```bash
# Delete data older than 2 days (default)
./scripts/cleanup-elasticsearch.sh 2

# Or more aggressive - delete older than 1 day
./scripts/cleanup-elasticsearch.sh 1
```

## Monitor Disk Usage

```bash
# Check disk space
curl http://localhost:9200/_cat/allocation?v

# Check index sizes
curl http://localhost:9200/_cat/indices?v&s=store.size:desc

# Check what will be deleted soon
curl http://localhost:9200/_ilm/explain/filebeat-*?pretty
```

## Customization

Want different retention periods? Edit these files:

- `elasticsearch/ilm-policies/logs-lifecycle-policy.json` (change "2d" to your preference)
- `elasticsearch/ilm-policies/metrics-lifecycle-policy.json` (change "2d" to your preference)

Then reapply: `./scripts/setup-elasticsearch-ilm.sh`

## Troubleshooting

### "Disk is full" error

```bash
# 1. Run immediate cleanup
./scripts/cleanup-elasticsearch.sh 1

# 2. If indices are read-only, unlock them
curl -X PUT "http://localhost:9200/_all/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index.blocks.read_only_allow_delete": null}'
```

### Check what's using space

```bash
curl http://localhost:9200/_cat/indices?v&h=index,store.size&s=store.size:desc
```

## Configuration Summary

**Disk Thresholds** (in docker-compose.yml):

- 85% - Warning, no new shards
- 90% - Start relocating data
- 95% - Read-only mode (emergency)

**Compression**: Enabled (saves ~30-40% space)

**Rollover Triggers**:

- Logs: Every 1 day OR 10GB
- Metrics: Every 1 day OR 10GB

---

For detailed documentation, see `elasticsearch/README.md`
