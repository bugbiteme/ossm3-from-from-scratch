```bash
# Find a ztunnel pod

ZTUNNEL_POD=$(oc get pod -n ztunnel -l app=ztunnel -o jsonpath='{.items[0].metadata.name}')

# Check logs for connection events
oc logs -n ztunnel $ZTUNNEL_POD -f
```