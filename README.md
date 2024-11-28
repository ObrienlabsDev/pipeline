# pipeline

## Architecture
### cert-manager
Including aws-pravateca-issuer, awspca-cert-pre-install-hook (job), trust-manager, cert-manager-csi-driver on top of the default cert-manager, cert-manager-cainjector, cert-manager-webhook


# Experimentation
## Revisit Helm
https://cert-manager.io/docs/installation/helm/
```
michaelobrien@mbp7 wse_github % mkdir pipeline
michaelobrien@mbp7 wse_github % cd pipeline 
michaelobrien@mbp7 pipeline % helm version                                     
version.BuildInfo{Version:"v3.16.2", GitCommit:"13654a52f7c70a143b1dd51416d633e1071faffb", GitTreeState:"dirty", GoVersion:"go1.23.2"}
michaelobrien@mbp7 pipeline % helm repo add jetstack https://charts.jetstack.io
"jetstack" has been added to your repositories
michaelobrien@mbp7 pipeline % helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
michaelobrien@mbp7 pipeline % helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version 1

michaelobrien@mbp7 pipeline % kubectl get pods --all-namespaces
NAMESPACE      NAME                                      READY   STATUS    RESTARTS         AGE
cert-manager   cert-manager-b6fd485d9-ggznv              1/1     Running   0                87m
cert-manager   cert-manager-cainjector-dcc5966bc-jn94h   1/1     Running   13 (5m47s ago)   87m
cert-manager   cert-manager-webhook-dfb76c7bd-jcghj      1/1     Running   0                87m
kube-system    aws-node-8bwzk                            2/2     Running   0                34d
kube-system    aws-node-f9mz4                            2/2     Running   0                34d
kube-system    coredns-586b798467-fdvwr                  1/1     Running   0                45d
kube-system    coredns-586b798467-gff7r                  1/1     Running   0                45d
kube-system    eks-pod-identity-agent-cq8nn              1/1     Running   0                34d
kube-system    eks-pod-identity-agent-g4wxv              1/1     Running   0                34d
kube-system    kube-proxy-b8v4z                          1/1     Running   0                34d
kube-system    kube-proxy-h2ttb                          1/1     Running   0                34d
michaelobrien@mbp7 pipeline % helm list
NAME	NAMESPACE	REVISION	UPDATED	STATUS	CHART	APP VERSION

try later

michaelobrien@mbp7 pipeline % helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.2 \
  --set crds.enabled=true \
  --set prometheus.enabled=false --set webhook.timeoutSeconds=4

```
