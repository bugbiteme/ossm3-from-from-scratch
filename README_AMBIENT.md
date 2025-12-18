# ossm3-from-from-scratch
Following official RH documentation
---
Tested on
```bash
Client Version: 4.20.6
Kustomize Version: v5.6.0
Server Version: 4.20.6
Kubernetes Version: v1.33.5

DISPLAY                            VERSION                                
Cluster Observability Operator     1.3.0      
Kiali Operator                     2.17.2    
Red Hat OpenShift GitOps           1.18.2      
Red Hat build of OpenTelemetry     0.140.0-1 
Red Hat OpenShift Service Mesh 3   3.2.1       
Tempo Operator                     0.19.0-1   
```
**Note: Tracing does not work at this time**

## Quick Setup 

You can manually install each component via the command line (reccomended for first time)

### Operators

```
oc apply -k operators
```

### MinIO (for s3 storage)

```
oc apply -k minio -n minio
```

### Enable User Monnitoring

```
oc apply -k observability
```

Verify that the `prometheus-operator`, `prometheus-user-workload`, and `thanos-ruler-user-workload` pods are running in the openshift-user-workload-monitoring project.

```bash
oc get pods -n openshift-user-workload-monitoring   
```

Output:
```bash
NAME                                   READY   STATUS    RESTARTS   AGE
prometheus-operator-854db99d74-v2fww   2/2     Running   0          117s
prometheus-user-workload-0             6/6     Running   0          116s
thanos-ruler-user-workload-0           4/4     Running   0          115s
```

### Tempo Stack and OpenTelemetry (for distributed Tracing)
```bash
oc apply -k  tempoStack-coo/tempoStack
oc apply -k tempoStack-coo/observability-plugin
```

### Service Mesh Istio System (ambient overlay)
``` bash
oc apply -k ossm/mesh/overlays/ambient
```

### Istio Gateway (with gateway-injection)
```bash
oc apply -k ossm/gateway-injection   
```


### Kiali
```bash
oc apply -k kiali
```

### Sample `bookinfo` App (to test tracing and Kiali)

```bash
oc apply -k bookinfo/overlays/ambient
HOST=$(oc get route istio-ingressgateway -n prod-gateway -o jsonpath='{.spec.host}')
echo productpage URL: https://$HOST/productpage
```    

Bookinfo load generator
```bash
export INGRESSHOST=$(oc get route istio-ingressgateway -n prod-gateway -o=jsonpath='{.spec.host}')
cat ./bookinfo/bookinfo-traffic-gen/traffic-generator-configmap.yaml | ROUTE="https://${INGRESSHOST}/productpage" envsubst | oc -n bookinfo apply -f - 
oc apply -f ./bookinfo/bookinfo-traffic-gen/traffic-generator.yaml -n bookinfo
```



### Additional Notes:

Check Ztunnel Logs: Check the logs of the `ztunnel` daemonset. You should see messages 
indicating that it has received configuration for your workloads.

```bash
 oc logs -n ztunnel -l app=ztunnel -f
```

```bash
# Find a ztunnel pod

ZTUNNEL_POD=$(oc get pod -n ztunnel -l app=ztunnel -o jsonpath='{.items[0].metadata.name}')

# Check logs for connection events
oc logs -n ztunnel $ZTUNNEL_POD -f
```

```bash
istioctl ztunnel-config workloads --namespace ztunnel
```
```bash
istioctl ztunnel-config workloads --namespace ztunnel
NAMESPACE    POD NAME                              ADDRESS      NODE                                     WAYPOINT PROTOCOL
bookinfo     details-v1-7cd5c659bc-nrngf           10.128.1.45  ip-10-0-59-58.us-east-2.compute.internal None     HBONE
bookinfo     productpage-v1-6b8fdb6c6b-zpwv8       10.128.1.46  ip-10-0-59-58.us-east-2.compute.internal None     HBONE
bookinfo     ratings-v1-59f666f7d7-5kpx2           10.128.1.47  ip-10-0-59-58.us-east-2.compute.internal None     HBONE
bookinfo     reviews-v1-d644f9c4c-hfgt7            10.128.1.48  ip-10-0-59-58.us-east-2.compute.internal None     HBONE
bookinfo     reviews-v2-7bb9fd95f7-sql7z           10.128.1.49  ip-10-0-59-58.us-east-2.compute.internal None     HBONE
bookinfo     reviews-v3-79d9c86c8c-z9knt           10.128.1.50  ip-10-0-59-58.us-east-2.compute.internal None     HBONE               10.128.0.234 ip-10-0-59-58.us-east-2.compute.internal None     TCP
```

