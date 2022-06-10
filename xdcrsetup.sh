#!/bin/sh
#Variables
DOCKER_ID="jadejakajal13"
DOCKER_API="b461d1b4-82c4-499e-afc0-f17943a16411"
DOCKER_EMAIL="jadejakajal13@gmail.com"
LICENSE_FILE="license.xml"
XDCR="XDCR2.yaml"


helm repo add santy https://voltdb-kubernetes-charts.storage.googleapis.com

#creating a cluster

gcloud beta container --project fourth-epigram-293718  clusters create xdcr1 --zone us-central1-a --no-enable-basic-auth --cluster-version "1.22.8-gke.201" --machine-type "n2-standard-2" --num-nodes 5 --disk-type "pd-standard" --disk-size "100"

#connecting to the cluster
gcloud container clusters get-credentials xdcr1 --zone us-central1-a --project fourth-epigram-293718

#create the secret registry
kubectl create secret docker-registry dockerio-registry --docker-username=$DOCKER_ID --docker-email=$DOCKER_EMAIL --docker-password=$DOCKER_API


helm install xdcr1 santy/voltdb --set cluster.clusterSpec.replicas=3 --set cluster.config.deployment.cluster.kfactor=1 --set-file cluster.config.licenseXMLFile=$LICENSE_FILE  -f $XDCR

sleep 360

echo "IP for volt UI access"

kubectl get nodes -o wide | tail -1 | awk -F " " {'print $7'}

echo "VolTB Port for UI access"

kubectl get svc  | grep http |awk -F " " {'print $5'}

echo " external load balancer ip"

kubectl get all | grep LoadBalancer | sed -n '1,1p' |awk '{ print $4 }' 

kubectl create -f votertest.yaml

sleep 180

kubectl cp run.sh votertestfinal:/opt/voltdb/voter/run.sh/
kubectl cp ddl.sql  votertestfinal:/opt/voltdb/voter/ddl.sql/
#kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh init"
#kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh client"


kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh init xdcr1-voltdb-cluster-client.default.svc.cluster.local"
kubectl exec -it votertestfinal -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh client xdcr1-voltdb-cluster-client.default.svc.cluster.local"

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "all job's completed"
fi

DOCKER_ID="jadejakajal13"
DOCKER_API="b461d1b4-82c4-499e-afc0-f17943a16411"
DOCKER_EMAIL="jadejakajal13@gmail.com"
LICENSE_FILE="license.xml"
XDCR="XDCR.yaml"

gcloud beta container --project fourth-epigram-293718  clusters create xdcr2 --zone us-central1-a --no-enable-basic-auth --cluster-version "1.22.8-gke.201" --machine-type "n2-standard-2" --num-nodes 5 --disk-type "pd-standard" --disk-size "100"

gcloud container clusters get-credentials xdcr2 --zone us-central1-a --project fourth-epigram-293718



kubectl create secret docker-registry dockerio-registry --docker-username=$DOCKER_ID --docker-email=$DOCKER_EMAIL --docker-password=$DOCKER_API

helm install xdcr2 santy/voltdb --set cluster.clusterSpec.replicas=3 --set cluster.config.deployment.cluster.kfactor=1 --set-file cluster.config.licenseXMLFile=$LICENSE_FILE  -f $XDCR

sleep 360
kubectl create -f votertest2.yaml



sleep 180

kubectl cp ddl.sql  votertestfinal2:/opt/voltdb/voter/ddl.sql/
kubectl cp run.sh votertestfinal2:/opt/voltdb/voter/run.sh/

kubectl exec -it votertestfinal2 -- /bin/bash -c "cd /opt/voltdb/voter/ ; ./run.sh init xdcr2-voltdb-cluster-client.default.svc.cluster.local"

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "all job's completed"
fi

echo "IP for volt UI access"

kubectl get nodes -o wide | tail -1 | awk -F " " {'print $7'}

echo "VolTB Port for UI access"

kubectl get svc  | grep http |awk -F " " {'print $5'}


gcloud container clusters get-credentials xdcr1 --zone us-central1-a --project fourth-epigram-293718

var1=`kubectl get all | grep LoadBalancer | sed -n '1,1p' |awk '{ print $4 }'`



gcloud container clusters get-credentials xdcr2 --zone us-central1-a --project fourth-epigram-293718

helm upgrade xdcr1 santy/voltdb --reuse-values --set cluster.config.deployment.dr.connection.source=$var1


var2=`kubectl get all | grep LoadBalancer | sed -n '1,1p' |awk '{ print $4 }'`
gcloud container clusters get-credentials xdcr1 --zone us-central1-a --project fourth-epigram-293718

helm upgrade xdcr2 santy/voltdb --reuse-values --set cluster.config.deployment.dr.connection.source=$var1













