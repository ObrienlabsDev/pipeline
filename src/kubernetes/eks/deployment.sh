#!/bin/bash
# create.sh

source ./vars.sh

deployment() {

  echo "Date: $(date)"
  echo "Timestamp: $(date +%s)"
  echo "$UNIQUE"
  echo "running with create=${CREATE_PROJ} delete=${DELETE_PROJ} boot_project_id=${BOOT_PROJECT_ID}"

if [[ "$CREATE_PROJ" != false ]]; then
  # linux
  #STREAM_PROJECT_RAND=$(shuf -i 0-10000 -n 1)
  # osx
  STREAM_PROJECT_RAND=$(jot -r 1 1000 10000)
  STREAM_PROJECT_ID=${STREAM_PROJECT_NAME_PREFIX}-${STREAM_PROJECT_RAND}
  echo "Creating: $STREAM_PROJECT_ID"

  createHostedZone

  switchKubernetesContexts

  deployCertManager
  sleep 2

  deployReloader
  deployApps

else
  #STREAM_PROJECT_ID=${STREAM_PROJECT_ID_PASSED}
  echo "Reusing project: $STREAM_PROJECT_ID"
fi

if [[ "$DELETE_PROJ" != false ]]; then
  echo "Deleting: $STREAM_PROJECT_ID"
  undeployApps
  undeployReloader
  undeployCertManager

fi

}

createHostedZone() {
    HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name $DOMAIN_NAME --query "HostedZones[0].Id" --output text)
  echo $HOSTED_ZONE_ID
  aws route53 get-hosted-zone --id ${HOSTED_ZONE_ID}
  # check dns - delay needed
  dig $DOMAIN_NAME ns +trace +nodnssec
}

switchKubernetesContexts() {
    # switch contexts without knowing the id
  aws eks update-kubeconfig --region us-east-1 --name prod
  # verify context star
  kubectl config get-contexts
}

deployCertManager() {
  echo "Deploy cert-manager"
  helm install cert-manager cert-manager \
  --repo https://charts.jetstack.io \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

  cmctl status certificate www
  cmctl inspect secret www-tls

  kubectl apply -f clusterissuer-selfsigned.yaml
  envsubst < certificate.yaml | kubectl apply -f -
}

undeployCertManager() {
  echo "unDeploy cert-manager"
}

deployReloader() {
  # from https://github.com/stakater/Reloader/blob/master/deployments/kubernetes/reloader.yaml
  # https://github.com/ObrienlabsDev/pipeline/issues/6
  echo "Deploy reloader"
  kubectl apply -f reloader.yaml 
}

undeployReloader() {
  echo "unDeploy reloader"
  kubectl delete -f reloader.yaml 
}

deployApps() {
  echo "Deploy apps"
  kubectl apply -f deployment.yaml
  sleep 5
  kubectl apply -f service.yaml
  # wait for 
  # helloweb   LoadBalancer   10.100.90.190   af42541db9a3c4072b6f64a1852d17df-346026318.us-east-1.elb.amazonaws.com   443:30921/TCP   6s
  sleep 5
  kubectl get service helloweb
}

undeployApps() {
  echo "unDeploy apps"
  kubectl delete -f deployment.yaml
  kubectl delete -f service.yaml
}



UNIQUE=old
CREATE_PROJ=false
DELETE_PROJ=false
PROVISION_PROJ=false
STREAM_PROJECT_ID=
BOOT_PROJECT_ID=
while getopts ":c:d:b:p:s:u:" PARAM; do
  case $PARAM in
    c)
      CREATE_PROJ=${OPTARG}
      ;;
    d)
      DELETE_PROJ=${OPTARG}
      ;;
    p)
      PROVISION_PROJ=${OPTARG}
      ;;
    b)
      BOOT_PROJECT_ID=${OPTARG}
      ;;
    s)
      STREAM_PROJECT_ID=${OPTARG}
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

#  echo "Options are: -c true/false (create) -d true/false (delete proj) -b BOOT_PROJ_ID"


if [[ -z $UNIQUE ]]; then
  usage
  exit 1
fi

#deployment "$CREATE_PROJ" "$DELETE_PROJ" "$PROVISION_PROJ" "$BOOT_PROJECT_ID" "$STREAM_PROJECT_ID"
deployReloader
printf "**** Done ****\n"