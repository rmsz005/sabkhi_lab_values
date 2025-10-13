# Music Storage for sabkhi_lab

This directory manages the shared music library storage used by multiple applications.

## Overview

The `music-library` PVC provides centralized storage for music files that are:
- Downloaded by **Spotizerr** (written to `/downloads`)
- Streamed by **Navidrome** (read from `/music`)

## Storage Details

- **PVC Name**: `music-library`
- **Namespace**: `media`
- **Size**: 100Gi (adjustable based on your music collection)
- **Storage Class**: `longhorn-nvme-replicated` (fast NVMe storage)
- **Access Mode**: `ReadWriteMany` (RWX) - allows multiple pods to mount simultaneously

## Architecture

```
┌─────────────────────────────────────────┐
│       music-library PVC (100Gi)         │
│     longhorn-nvme-replicated (RWX)      │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
       ▼                ▼
┌──────────────┐  ┌─────────────┐
│  Spotizerr   │  │  Navidrome  │
│              │  │             │
│  Writes to:  │  │  Reads from:│
│  /downloads  │  │  /music     │
│  (namespace: │  │  (namespace:│
│   media)     │  │   media)    │
└──────────────┘  └─────────────┘
```

## Why ReadWriteMany (RWX)?

- **Spotizerr** actively writes music files
- **Navidrome** reads and indexes the same files
- RWX allows both to access the volume simultaneously
- Longhorn supports RWX mode natively

## Usage in Applications

### Spotizerr Configuration

```yaml
spotizerr:
  persistence:
    downloads:
      enabled: true
      existingClaim: "music-library"
      # Chart creates PVC by default, but existingClaim prevents it
```

### Navidrome Configuration

```yaml
persistence:
  music:
    enabled: true
    type: pvc
    existingClaim: "music-library"
    # References the same PVC created by music-storage
```

## Access Pattern

1. **Spotizerr** downloads music → writes to PVC at `/downloads`
2. **Navidrome** scans for music → reads from PVC at `/music` (same physical location)
3. Both applications see the same files because they mount the same PVC

## Storage Sizing Guidance

- **50-100Gi**: Small music collection (~5,000-10,000 tracks)
- **200-500Gi**: Medium collection (~20,000-50,000 tracks)
- **1Ti+**: Large collection (50,000+ tracks, lossless formats)

Current setting: **100Gi** (expandable via Longhorn volume expansion)

## Backup Recommendations

Since this PVC contains your entire music library:

1. **Enable Longhorn recurring backups** for this volume
2. **Schedule**: Daily incremental backups
3. **Retention**: Keep at least 7 days of backups
4. **Off-site**: Configure Longhorn backup target (S3, NFS, etc.)

## Expansion

To expand storage:

```bash
kubectl patch pvc music-library -n media -p '{"spec":{"resources":{"requests":{"storage":"200Gi"}}}}'
```

Longhorn will automatically expand the volume (no downtime required).

## Troubleshooting

### Check PVC Status
```bash
kubectl get pvc music-library -n media
kubectl describe pvc music-library -n media
```

### Check Which Pods Are Using It
```bash
kubectl get pods --all-namespaces -o json | \
  jq -r '.items[] | select(.spec.volumes[]?.persistentVolumeClaim?.claimName=="music-library") | "\(.metadata.namespace)/\(.metadata.name)"'
```

### View Longhorn Volume Details
Access Longhorn UI at `https://longhorn.internal.rmsz005.com` and search for the volume.
