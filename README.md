# pipeline
Update 20241211

## Problem
I need a way to deploy, run and SRE maintain a set of microservices - some of which may require specialized services like use of Apple Metal or NVidia CUDA GPUs.  I can use a CSP like GCP, AWS or Azure and lock into their FaaS or PaaS.  I could run cloud native using kubernetes on the CSP or locally on VMs or bare metal.  I could go old school and run each service on its' own VM/Machine.  I could go pre-kubernetes and run the applications on a large server using just docker or containerd - but miss out on horizontal scaling.  I would like to get the benefits of a full CI/CD pipeline that is AI driven through monitoring and metrics - as close to an automated DevOps / SRE as possible.  In the end I will go mainstream but with an eye to optimized FinOps and deploy to a kubernetes cluster locally.
## Solution

## Deployment
### Install kubectl
### Get a Kubernetes Cluster
  I have installed EKS on AWS, we can also use GKE on GCP, docker-desktop, minikube, one or more Mac Mini M4s or a CAPI/kubeadm cluster on Raspberry PI 5s
#### Mac Mini M4 Cluster
<img width="1418" alt="Screenshot 2025-02-12 at 21 53 04" src="https://github.com/user-attachments/assets/24aec9a7-8e8c-4430-8828-e7464ecd74b4" />

#### Raspberry PI 5 Cluster
<img width="1419" alt="Screenshot 2025-02-12 at 21 59 58" src="https://github.com/user-attachments/assets/431532f6-ed0f-43d8-a9d4-7e6222dbba24" />

  
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

## Install Jenkins via Helm
20250513
https://github.com/ObrienlabsDev/pipeline/issues/14
```
mkdir jenkins
cd jenkins 
helm repo add jenkins https://charts.jenkins.io
"jenkins" has been added to your repositories
michaelobrien@Mac jenkins % helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "ingress-nginx" chart repository
...Successfully got an update from the "jenkins" chart repository
...Successfully got an update from the "datadog" chart repository
Update Complete. ⎈Happy Helming!⎈
helm list
NAME         	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART         	APP VERSION
datadog-agent	default  	2       	2024-12-18 16:09:02.076673 -0500 EST	deployed	datadog-3.83.1	7
% helm search repo jenkins
NAME           	CHART VERSION	APP VERSION	DESCRIPTION                                       
jenkins/jenkins	5.8.43       	2.504.1    	Jenkins - Build great things at any scale! As t...
% helm install jenkins jenkins/jenkins 
NAME: jenkins
LAST DEPLOYED: Tue May 13 10:22:00 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  echo http://127.0.0.1:8080
  kubectl --namespace default port-forward svc/jenkins 8080:8080

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://127.0.0.1:8080/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/
NOTE: Consider using a custom image with pre-installed plugins     

kubectl get pods | grep jenkins
jenkins-0                                      0/2     Pending   0          86s
 kubectl get events
LAST SEEN   TYPE      REASON             OBJECT                          MESSAGE
3m33s       Warning   Unhealthy          pod/datadog-agent-5dfv5         Readiness probe failed: HTTP probe failed with statuscode: 500
3m35s       Warning   Unhealthy          pod/datadog-agent-795sx         Readiness probe failed: HTTP probe failed with statuscode: 500
95s         Warning   FailedScheduling   pod/jenkins-0                   0/2 nodes are available: pod has unbound immediate PersistentVolumeClaims. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
8s          Normal    FailedBinding      persistentvolumeclaim/jenkins   no persistent volumes available for this claim and no storage class is set
95s         Normal    SuccessfulCreate   statefulset/jenkins             create Pod jenkins-0 in StatefulSet jenkins successful    
```

## Revisit EKS
- https://github.com/ObrienlabsDev/pipeline/issues/3
- https://github.com/cert-manager/cert-manager?tab=readme-ov-file
- https://cert-manager.io/docs/getting-started/
- https://cert-manager.io/docs/tutorials/getting-started-aws-letsencrypt/

```

```
