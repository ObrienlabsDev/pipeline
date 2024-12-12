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


  HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name $DOMAIN_NAME --query "HostedZones[0].Id" --output text)
  echo $HOSTED_ZONE_ID
  aws route53 get-hosted-zone --id ${HOSTED_ZONE_ID}
  # check dns - delay needed
  dig $DOMAIN_NAME ns +trace +nodnssec
  # switch contexts without knowing the id
  aws eks update-kubeconfig --region us-east-1 --name prod
  # verify context star
  kubectl config get-contexts


  #kubectl apply -f clusterissuer-selfsigned.yaml
  #envsubst < certificate.yaml | kubectl apply -f -


else
  #STREAM_PROJECT_ID=${STREAM_PROJECT_ID_PASSED}
  echo "Reusing project: $STREAM_PROJECT_ID"
fi

if [[ "$DELETE_PROJ" != false ]]; then
  echo "Deleting: $STREAM_PROJECT_ID"
fi

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

deployment "$CREATE_PROJ" "$DELETE_PROJ" "$PROVISION_PROJ" "$BOOT_PROJECT_ID" "$STREAM_PROJECT_ID"
printf "**** Done ****\n"