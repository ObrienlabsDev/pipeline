# pipeline
Update 20241211

## Problem
I need a way to deploy, run and SRE maintain a set of microservices - some of which may require specialized services like use of Apple Metal or NVidia CUDA GPUs.  I can use a CSP like GCP, AWS or Azure and lock into their FaaS or PaaS.  I could run cloud native using kubernetes on the CSP or locally on VMs or bare metal.  I could go old school and run each service on its' own VM/Machine.  I could go pre-kubernetes and run the applications on a large server using just docker or containerd - but miss out on horizontal scaling.  I would like to get the benefits of a full CI/CD pipeline that is AI driven through monitoring and metrics - as close to an automated DevOps / SRE as possible.  In the end I will go mainstream but with an eye to optimized FinOps and deploy to a kubernetes cluster locally.
## Solution

## Deployment
### Install kubectl
### Get a Kubernetes Cluster
  I have installed EKS on AWS, we can also use GKE on GCP, docker-desktop, minikube or a CAPI/kubeadm cluster on Raspberry PI 5s
```
kubectl config get-contexts
CURRENT   NAME                                              CLUSTER                                           AUTHINFO                                          NAMESPACE
      arn:aws:eks:us-east-1:4....0:cluster/prod   arn:aws:eks:us-east-1:4....0:cluster/prod   arn:aws:eks:us-east-1:4....0:cluster/prod   
      docker-desktop                                    docker-desktop                                    docker-desktop                                    
      minikube                                          minikube                                          minikube                                          
```
#### Install eksctl
- https://docs.aws.amazon.com/eks/latest/userguide/setting-up.html
- https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#eksctl-install-update
- https://eksctl.io/installation/
```
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
(venv-metal) michaelobrien@Michaels-MBP eks % eksctl version  
0.197.0
```

## Architecture
### cert-manager
Including aws-pravateca-issuer, awspca-cert-pre-install-hook (job), trust-manager, cert-manager-csi-driver on top of the default cert-manager, cert-manager-cainjector, cert-manager-webhook


# Experimentation
## Revisit Helm
- https://github.com/ObrienlabsDev/pipeline/issues/2
- https://cert-manager.io/docs/installation/helm/
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

## Revisit EKS
- https://github.com/ObrienlabsDev/pipeline/issues/3
- https://github.com/cert-manager/cert-manager?tab=readme-ov-file
- https://cert-manager.io/docs/getting-started/
- https://cert-manager.io/docs/tutorials/getting-started-aws-letsencrypt/

```

```
