#!/bin/sh
#Variables
DOCKER_ID="jadejakajal13"
DOCKER_API="b461d1b4-82c4-499e-afc0-f17943a16411"
DOCKER_EMAIL="jadejakajal13@gmail.com"
LICENSE_FILE="/opt/voltdb/voltdb/license.xml"
XDCR2="XDCR2.yaml"


helm repo add santy https://voltdb-kubernetes-charts.storage.googleapis.com

#creating a cluster

gcloud beta container --project fourth-epigram-293718 clusters create xdcr1 --zone us-east4-a --no-enable-basic-auth --cluster-version "1.22.6-gke.300" --machine-type "n2-standard-2" --disk-type "pd-standard" --disk-size "100" --num-nodes "3"

#connecting to the cluster
gcloud container clusters get-credentials xdcr1 --zone us-east4-a --project fourth-epigram-293718

#create the secret registry
kubectl create secret docker-registry dockerio-registry --docker-username=$DOCKER_ID --docker-email=$DOCKER_EMAIL --docker-password=$DOCKER_API


helm install xdcr1 santy/voltdb --set cluster.clusterSpec.replicas=3 --set cluster.config.deployment.cluster.kfactor=1 --set-file cluster.config.licenseXMLFile=$LICENSE_FILE  -f $XDCR2

sleep 360

kubectl port-forward xdcr1-voltdb-cluster-0 8080 21212

kubectl get all | grep LoadBalancer | sed -n '1,1p' |awk '{ print $4 }' > temp

cat temp

