# Run this script after gitops deployment completes to ensure pods are in a healthy state
# Known namespaces that this helps:
# - bookinfo (ensure proxy-sidecar deployment)
# - prod-gateway (one pod hangs for some reason)

# oc -n <namespace> get deploy -o name | xargs -r -L1 oc -n <namespace> rollout restart

for i in bookinfo prod-gateway
do 
  oc -n $i get deploy -o name | xargs -r -L1 oc -n $i rollout restart
done

# Bookinfo Traffic Generator

export INGRESSHOST=$(oc get route istio-ingressgateway -n prod-gateway -o=jsonpath='{.spec.host}')
cat ./bookinfo/bookinfo-traffic-gen/traffic-generator-configmap.yaml | ROUTE="https://${INGRESSHOST}/productpage" envsubst | oc -n bookinfo apply -f - 
oc apply -f ./bookinfo/bookinfo-traffic-gen/traffic-generator.yaml -n bookinfo