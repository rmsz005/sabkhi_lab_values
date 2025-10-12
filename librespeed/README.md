# LibreSpeed

LibreSpeed is a lightweight, privacy-friendly HTML5 network speed test tool.

## Features

- ✅ **Accurate Upload Tests**: Unlike OpenSpeedTest, LibreSpeed properly processes upload data
- ✅ **Download Tests**: Tests download speeds with configurable file sizes
- ✅ **Ping/Latency**: Measures latency and jitter
- ✅ **No External Dependencies**: Self-hosted solution, no data sent to third parties
- ✅ **Multi-Server Support**: Can test against multiple servers
- ✅ **Results Storage**: Optional database support for storing historical results

## Access

The application is accessible at:
- **URL**: https://speedtest.internal.rmsz005.com

## Configuration

### Image Version

Currently using:
- **Chart Version**: 5.4.2
- **App Version**: 5.4.1-ls246 (linuxserver/librespeed)

### Environment Variables

Edit `values.yaml` to configure:

```yaml
env:
  TZ: UTC                    # Timezone
  PUID: "1001"               # User ID
  PGID: "1001"               # Group ID
  PASSWORD: "password"       # Password protect results page (optional)
```

### Database Support

To store test results, configure database settings:

```yaml
env:
  DB_TYPE: "mysql"           # mysql, postgresql, or sqlite
  DB_NAME: "librespeed"
  DB_HOSTNAME: "mysql.default.svc"
  DB_USERNAME: "librespeed"
  DB_PASSWORD: "password"
  DB_PORT: "3306"
```

### Persistence

To enable persistent storage for configuration:

```yaml
persistence:
  config:
    enabled: true
    mountPath: /config
    storageClass: "longhorn"
    size: 1Gi
```

## Nginx Configuration

The ingress is configured with:
- **50MB body size limit** for upload tests
- **Compression disabled** to ensure accurate measurements
- **Buffering disabled** to prevent latency issues

## Upgrade

To update to a newer version:

1. Check latest image tag:
   ```bash
   curl -s https://registry.hub.docker.com/v2/repositories/linuxserver/librespeed/tags | \
     jq -r '.results[].name' | grep -E "^5\." | head -10
   ```

2. Update `values.yaml`:
   ```yaml
   image:
     tag: "5.4.1-ls246"  # Update to new version
   ```

3. Commit and push changes

## Comparison with OpenSpeedTest

| Feature | LibreSpeed | OpenSpeedTest |
|---------|-----------|---------------|
| Upload Tests | ✅ Accurate | ❌ Measures buffer writes |
| Download Tests | ✅ Working | ✅ Working |
| Compression Issues | ✅ Generates random data | ❌ Compressible data |
| Results Storage | ✅ Database support | ❌ Client-side only |
| Multi-Server | ✅ Supported | ✅ Supported |

## Troubleshooting

### Upload speeds still unrealistic?

1. Check nginx compression is disabled:
   ```bash
   kubectl get ingress -n librespeed librespeed -o yaml | grep -A5 server-snippet
   ```

2. Test with curl to bypass browser:
   ```bash
   dd if=/dev/urandom of=/tmp/test-50MB.bin bs=1M count=50
   curl -X POST https://speedtest.internal.rmsz005.com/backend/empty.php \
     --data-binary "@/tmp/test-50MB.bin" \
     -w "\nSpeed: %{speed_upload} bytes/sec\n"
   ```

3. Check pod logs:
   ```bash
   kubectl logs -n librespeed -l app.kubernetes.io/name=librespeed
   ```

## References

- [LibreSpeed GitHub](https://github.com/librespeed/speedtest)
- [LibreSpeed Docker Hub](https://hub.docker.com/r/linuxserver/librespeed)
- [k8s-at-home Chart](https://artifacthub.io/packages/helm/geek-cookbook/librespeed)

