#!/bin/sh
#Variables
DOCKER_ID="jadejakajal13"
DOCKER_API="b461d1b4-82c4-499e-afc0-f17943a16411"
DOCKER_EMAIL="jadejakajal13@gmail.com"
LICENSE_FILE="license.xml"
XDCR="XDCR2.yaml"


helm repo add santy https://voltdb-kubernetes-charts.storage.googleapis.com

#creating a cluster

gcloud beta container --project santosh-350416  clusters create xdcr1 --zone us-central1-a --no-enable-basic-auth --cluster-version "1.22.6-gke.300" --machine-type "n2-standard-2" --num-nodes 5 --disk-type "pd-standard" --disk-size "100"

#connecting to the cluster
gcloud container clusters get-credentials xdcr1 --zone us-central1-a --project santosh-350416

#create the secret registry
kubectl create secret docker-registry dockerio-registry --docker-username=$DOCKER_ID --docker-email=$DOCKER_EMAIL --docker-password=$DOCKER_API


helm install xdcr1 santy/voltdb --set cluster.clusterSpec.replicas=3 --set cluster.config.deployment.cluster.kfactor=1 --set-file cluster.config.licenseXMLFile=$LICENSE_FILE  -f $XDCR

sleep 360

#kubectl port-forward xdcr-voltdb-cluster-0 8080 21212

echo "IP for volt UI access"

kubectl get nodes -o wide | tail -1 | awk -F " " {'print $7'}

#echo "VolTB Port for UI access"

kubectl get svc  | grep http |awk -F " " {'print $5'}

#echo " external load balancer ip"

kubectl get all | grep LoadBalancer | sed -n '1,1p' |awk '{ print $4 }' 

#working

#kubectl cp voter/*/  xdcr1-voltdb-cluster-0:/dev/ 
#kubectl cp voter/voter-procs.jar  xdcr1-voltdb-cluster-0:/tmp/ 
#kubectl cp voter/run.sh  xdcr1-voltdb-cluster-0:/tmp/
#kubectl exec -it xdcr1-voltdb-cluster-0 -- sqlcmd < voter/ddl.sql
#kubectl exec -it xdcr1-voltdb-cluster-0 -- /bin/bash -c "/tmp/run.sh init"
#kubectl exec -it xdcr1-voltdb-cluster-0 -- voter/run.sh client
#kubectl cp voter  xdcr1-voltdb-cluster-0:/etc/





