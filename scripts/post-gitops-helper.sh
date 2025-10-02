# Run this script after gitops deployment completes to ensure pods are in a healthy state
# Known namespaces that this helps:
# - bookinfo (ensure proxy-sidecar deployment)
# - prod-gateway (one pod hangs for some reason)

# oc -n <namespace> get deploy -o name | xargs -r -L1 oc -n <namespace> rollout restart

for i in bookinfo prod-gateway
do 
  oc -n $i get deploy -o name | xargs -r -L1 oc -n $i rollout restart
done