# Kibana Deployment

This directory contains the Helm values for deploying Kibana using the ECK (Elastic Cloud on Kubernetes) operator.

## Architecture

- **Chart**: eck-kibana 0.16.0
- **Version**: Kibana 9.1.0
- **Namespace**: elasticsearch (same as Elasticsearch)
- **Ingress**: Enabled with TLS via cert-manager

## Components

### Kibana Instance
- **Replicas**: 1
- **Memory**: 1-2Gi per container
- **CPU**: 0.5-2 cores per container
- **Connected to**: elasticsearch cluster in the same namespace

## Access Kibana

### Via Ingress (Recommended)
Kibana is accessible at:
```
https://kibana.internal.rmsz005.com
```

The ingress is configured with:
- **TLS**: Automatic certificate from Let's Encrypt via cert-manager
- **DNS**: Wildcard DNS `*.internal.rmsz005.com` → `192.168.1.240`
- **Ingress Controller**: NGINX

### Via Port-Forward (Development/Debugging)
```bash
kubectl port-forward service/kibana-kb-http -n elasticsearch 5601:5601

# Access at:
# http://localhost:5601
```

### Internal Service URL (from within cluster)
```
http://kibana-kb-http.elasticsearch.svc.cluster.local:5601
```

## Login Credentials

Use the Elasticsearch credentials:

```bash
# Get the elastic user password
kubectl get secret elasticsearch-es-elastic-user -n elasticsearch \
  -o go-template='{{.data.elastic | base64decode}}'
```

**Username**: `elastic`  
**Password**: Retrieved from the command above

## Features

### Ingress Configuration
- ✅ HTTPS with automatic TLS certificates
- ✅ WebSocket support for real-time features
- ✅ Large payload support (no size limit)
- ✅ Extended timeouts (600s) for long-running queries

### Kibana Configuration
- ✅ Connected to local Elasticsearch cluster
- ✅ Public base URL configured for proper redirect handling
- ✅ TLS disabled on pod (terminated at ingress)
- ✅ Optimized Node.js memory settings

## Monitoring

Check Kibana status:
```bash
# Get Kibana resource
kubectl get kibana -n elasticsearch

# Check pods
kubectl get pods -n elasticsearch -l common.k8s.elastic.co/type=kibana

# View logs
kubectl logs -n elasticsearch -l common.k8s.elastic.co/type=kibana

# Check ingress
kubectl get ingress -n elasticsearch
kubectl describe ingress kibana -n elasticsearch
```

## Troubleshooting

### Kibana Pod Not Starting
```bash
# Check events
kubectl describe kibana kibana -n elasticsearch

# Check pod logs
kubectl logs -n elasticsearch <kibana-pod-name>

# Common issues:
# - Can't connect to Elasticsearch (check elasticsearchRef)
# - Memory issues (increase resources)
# - Certificate issues (check cert-manager)
```

### Cannot Access via Ingress
```bash
# Check ingress status
kubectl get ingress kibana -n elasticsearch

# Check cert-manager certificate
kubectl get certificate -n elasticsearch
kubectl describe certificate kibana-tls -n elasticsearch

# Check nginx ingress controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx <nginx-controller-pod>

# Verify DNS resolution
nslookup kibana.internal.rmsz005.com
```

### Login Issues
```bash
# Verify Elasticsearch is accessible from Kibana
kubectl exec -n elasticsearch <kibana-pod> -- \
  curl -k https://elasticsearch-es-http:9200

# Check if elastic user credentials are correct
kubectl get secret elasticsearch-es-elastic-user -n elasticsearch \
  -o go-template='{{.data.elastic | base64decode}}' && echo
```

## Scaling

Kibana can be scaled horizontally for high availability:

```yaml
# Edit kibana/values.yaml
count: 2  # Change from 1 to 2
```

**Note**: When running multiple Kibana instances, ensure:
- Elasticsearch is accessible
- Session persistence is handled (sticky sessions or shared session storage)

## Configuration Customization

### Enable Kibana Plugins
Edit `kibana/values.yaml`:
```yaml
podTemplate:
  spec:
    initContainers:
    - name: install-plugins
      command:
      - sh
      - -c
      - |
        bin/kibana-plugin install <plugin-url>
```

### Configure Kibana Settings
Add more settings to the `config` section:
```yaml
config:
  server.publicBaseUrl: "https://kibana.internal.rmsz005.com"
  # Increase timeout for long-running queries
  elasticsearch.requestTimeout: 90000
  # Configure logging
  logging.root.level: info
```

### Custom Domain
To use a different domain:
```yaml
config:
  server.publicBaseUrl: "https://your-domain.com"

ingress:
  hosts:
  - host: your-domain.com
    paths:
    - path: /
      pathType: Prefix
  tls:
  - secretName: your-domain-tls
    hosts:
    - your-domain.com
```

## Integration with Monitoring

Kibana metrics can be monitored using:
1. **Stack Monitoring**: Configure `monitoring` section in values
2. **Prometheus**: Kibana exposes metrics at `/api/status`
3. **Logs**: Collected by Promtail and stored in Loki

## Next Steps

1. **Configure Index Patterns**: Set up index patterns for your data
2. **Create Dashboards**: Build visualizations and dashboards
3. **Set up Alerts**: Configure alerting rules
4. **Enable Security**: Configure RBAC and spaces
5. **Add Fleet**: Deploy Elastic Agent and Fleet Server for data collection

## References

- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)
- [ECK Kibana Guide](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-kibana.html)
- [Kibana Configuration](https://www.elastic.co/guide/en/kibana/current/settings.html)


