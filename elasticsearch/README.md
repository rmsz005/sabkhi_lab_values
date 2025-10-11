# Elasticsearch Deployment

This directory contains the Helm values for deploying Elasticsearch using the ECK (Elastic Cloud on Kubernetes) operator.

## Architecture

- **Operator**: ECK Operator 3.1.0 (deployed in `elastic-system` namespace)
- **Chart**: eck-elasticsearch 0.16.0
- **Version**: Elasticsearch 9.1.0
- **Namespace**: elasticsearch

## Components

### ECK Operator
Manages Elasticsearch and other Elastic Stack resources as Kubernetes custom resources.

### Elasticsearch Cluster
- **Nodes**: 1 node (lab environment)
- **Storage**: 10Gi persistent volume per node
- **Memory**: 2-4Gi per container
- **CPU**: 0.5-2 cores per container

## Access Elasticsearch

### Get the password for the elastic user:
```bash
kubectl get secret elasticsearch-es-elastic-user -n elasticsearch -o go-template='{{.data.elastic | base64decode}}'
```

### Port-forward to access Elasticsearch:
```bash
kubectl port-forward service/elasticsearch-es-http -n elasticsearch 9200:9200
```

### Test the connection:
```bash
# Get password first
PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -n elasticsearch -o go-template='{{.data.elastic | base64decode}}')

# Test connection (uses self-signed cert)
curl -u "elastic:$PASSWORD" -k "https://localhost:9200"
```

## Monitoring

To monitor Elasticsearch, check the pods:
```bash
kubectl get elasticsearch -n elasticsearch
kubectl get pods -n elasticsearch
kubectl logs -f <pod-name> -n elasticsearch
```

## Scaling

To scale the cluster, update the `count` field in `values.yaml`:
```yaml
nodeSets:
- name: default
  count: 3  # Change from 1 to 3
```

## References

- [ECK Documentation](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [ECK Helm Charts](https://github.com/elastic/cloud-on-k8s/tree/main/deploy)

