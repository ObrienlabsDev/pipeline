# pipeline

# Experimentation
## Revisit Helm
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

```
