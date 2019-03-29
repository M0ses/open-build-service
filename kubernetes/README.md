```
 kubectl apply -f test-leap.yaml
 kubectl exec -it test-leap-pod -- /bin/bash
```

# Add kube-registry as insecure registry on each node

SEE /etc/containers/registries.conf

```
rccrio restart
```
