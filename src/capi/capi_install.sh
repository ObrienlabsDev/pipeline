# 20250223: michael at obrienlabs.cloud
# CAPI management server addition to docker desktop
# OSX
# https://cluster-api.sigs.k8s.io/user/quick-start
# run with sudo

# install KIND
#[ $(uname -m) = arm64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-darwin-arm64
#chmod +x ./kind
#mv ./kind ~/opt/kind

kubectl config get-contexts

cat > kind-cluster-with-extramounts.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: dual
nodes:
- role: control-plane
  extraMounts:
    - hostPath: /var/run/docker.sock
      containerPath: /var/run/docker.sock
EOF


kind create cluster --config kind-cluster-with-extramounts.yaml
kubectl cluster-info --context kind-kind
kubectl get nodes

# install clusterctl
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.9.5/clusterctl-darwin-amd64 -o clusterctl
chmod +x ./clusterctl
sudo mv ./clusterctl /usr/local/bin/clusterctl
clusterctl version

# initialize the cluster for the docker provider
export CLUSTER_TOPOLOGY=true
echo "Initialize the cluster"
clusterctl init --infrastructure docker

export SERVICE_CIDR=["10.96.0.0/12"]
export POD_CIDR=["192.168.0.0/16"]
export SERVICE_DOMAIN="k8s.test"
export POD_SECURITY_STANDARD_ENABLED="false"

clusterctl generate cluster capi-quickstart --flavor development --kubernetes-version v1.32.0 --control-plane-machine-count=3 --worker-machine-count=3 > capi-quickstart.yaml
echo "sleep 30sec before getting pods (before)"
sleep 30
kubectl get pods -A

echo "sleep 30sec more before applying the capi cluster yaml"
sleep 30
kubectl apply -f capi-quickstart.yaml
echo "sleep 2 min - wait for cluster"
sleep 120
echo "kubectl get cluster"
kubectl get cluster
echo "cluster describe cluster"
clusterctl describe cluster capi-quickstart

# verify controlplane
kubectl get kubeadmcontrolplane

echo "sleep 30sec"
sleep 30
# get kubeconfig
kind get kubeconfig --name capi-quickstart > capi-quickstart.kubeconfig

# deploy cloud provider

# deploy cni


# delete
#kubectl delete cluster capi-quickstart
#kind delete cluster
