#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal 'Couldnt source this'
set -e

#PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")

# Cluster 1
yellow Lets recall that: CLUSTER_1="$CLUSTER_1"
yellow Lets recall that: CLUSTER_2="$CLUSTER_2"
#yellow "Try now for cluster1=$CLUSTER_1 kubectl apply -f  k8s/multi-cluster-lb-setup/cluster1/"

kubectl config get-contexts

set -x

gcloud container clusters get-credentials "$CLUSTER_1" --region "$GCLOUD_REGION" --project "$PROJECT_ID"
kubectl apply -f  k8s/multi-cluster-lb-setup/cluster1/

gcloud container clusters get-credentials "$CLUSTER_2" --region "$GCLOUD_REGION" --project "$PROJECT_ID"
#kubectl config get-contexts
kubectl apply -f  k8s/multi-cluster-lb-setup/cluster2/

echo Restoring cluster 1.
gcloud container clusters get-credentials "$CLUSTER_1"  --region "$GCLOUD_REGION" --project "$PROJECT_ID"


echo Everything is ok.