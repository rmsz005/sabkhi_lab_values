# Network Benchmark Suite

Simple network benchmarks to test cluster network health across all nodes.

## How It Works

Pods schedule randomly across your cluster nodes. The **mesh test (11)** creates multiple pairs that will distribute across all available nodes, giving you cluster-wide network testing.

## Benchmark Files

| File | Test | What It Measures | Runtime |
|------|------|------------------|---------|
| `10-net-tcp-bandwidth.yaml` | TCP Bandwidth | Basic TCP throughput (4 streams) | ~3 min |
| `11-net-cluster-mesh.yaml` | Cluster Mesh | Network across all nodes (4 pairs) | ~3 min |
| `12-net-latency.yaml` | Latency | Network latency (single stream) | ~3 min |
| `13-net-udp-packet-loss.yaml` | UDP + Packet Loss | UDP performance and packet loss | ~3 min |

**Total runtime for all tests: ~12 minutes**

## Quick Start

### Run All Tests (Sequentially)
```bash
cd /path/to/benchmark-operator/examples

# Run each test one at a time
kubectl apply -f 10-net-tcp-bandwidth.yaml
# Wait 3-4 minutes for completion

kubectl apply -f 11-net-cluster-mesh.yaml
# Wait 3-4 minutes

kubectl apply -f 12-net-latency.yaml
# Wait 3-4 minutes

kubectl apply -f 13-net-udp-packet-loss.yaml
# Wait 3-4 minutes
```

### Simple Runner Script
```bash
#!/bin/bash
for file in 1{0..3}-net-*.yaml; do
  echo "Running $file..."
  kubectl apply -f "$file"
  
  # Wait for completion (simple approach)
  sleep 240  # 4 minutes
  
  echo "Completed $file"
done
```

## Monitor Progress

```bash
# Watch benchmarks
kubectl get benchmarks -n benchmark-operator -w

# View specific benchmark
kubectl describe benchmark net-tcp-bandwidth -n benchmark-operator

# Check pods
kubectl get pods -n benchmark-operator

# View logs (iperf3)
kubectl logs -n benchmark-operator -l app=iperf3-bench-client
kubectl logs -n benchmark-operator -l app=iperf3-bench-server
```

## View Results

### From Elasticsearch
```bash
# Query iperf3 results
curl -k -u elastic:PASSWORD \
  https://elasticsearch-es-http.elasticsearch.svc:9200/ripsaw-iperf3-*/_search?pretty
```

### From Kibana
Create simple dashboards for:
- Bandwidth over time
- Latency percentiles
- Packet loss rates

## What to Look For

### Good Results
- **TCP Bandwidth**: Close to your network speed (1/10/25 Gbps)
- **Latency**: < 1ms within datacenter
- **Packet Loss**: < 0.1%
- **Mesh test**: Similar performance across all pairs

### Problems
- Very low bandwidth (< 50% of network speed)
- High latency (> 10ms in LAN)
- Packet loss > 1%
- Large variation between mesh pairs (indicates node issues)

## Cleanup

```bash
# Delete benchmarks
kubectl delete benchmarks --all -n benchmark-operator

# Clean up pods
kubectl delete pods -n benchmark-operator --all
```

## Tips

1. **Run sequentially** - One test at a time to avoid interference
2. **Check all pairs in mesh test** - If one pair is slow, that node may have issues
3. **Run during off-peak** - Avoid testing during heavy cluster usage
4. **Baseline first** - Run tests when cluster is healthy to establish baseline
5. **Test regularly** - Monthly tests catch degradation early

## Troubleshooting

### Benchmark Stuck
```bash
kubectl get pods -n benchmark-operator
kubectl logs -n benchmark-operator <pod-name>
kubectl delete benchmark <name> -n benchmark-operator
```

### Low Performance
- Check node resources: `kubectl top nodes`
- Check network plugin: `kubectl get pods -n kube-system`
- Verify MTU settings on nodes
- Check for network throttling

### Results Not in Elasticsearch
- Verify ES is running: `kubectl get pods -n elasticsearch`
- Check connectivity: `kubectl run curl --image=curlimages/curl -it --rm -- curl -k https://elasticsearch-es-http.elasticsearch.svc:9200`

## References

- [Benchmark Operator](https://github.com/cloud-bulldozer/benchmark-operator)
- [iperf3 Documentation](https://iperf.fr/iperf-doc.php)
- [uperf Documentation](http://uperf.org/)
