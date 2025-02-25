#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
#set -x
set -e

function show_k8s_stuff() {
#     GKE_DEV_CLUSTER_CONTEXT="gke_cicd-platinum-test001_europe-west6_cicd-dev"
# GKE_CANARY_CLUSTER_CONTEXT="gke_cicd-platinum-test001_europe-west6_cicd-canary"
# GKE_PROD_CLUSTER_CONTEXT="gke_cicd-platinum-test001_europe-west6_cicd-prod"
    # I have 3 clusters and for each I want to show things..
    for CONTEXT in $GKE_DEV_CLUSTER_CONTEXT $GKE_CANARY_CLUSTER_CONTEXT $GKE_PROD_CLUSTER_CONTEXT ; do 
        yellow "== ClusterContext: $CONTEXT =="
        # https://stackoverflow.com/questions/33942709/run-a-single-kubectl-command-for-a-specific-project-and-cluster
        # if it doesnt work this should work: kubectl config use-context CONTEXT_NAME
        echodo kubectl --context="$CONTEXT" get service,gatewayclass 2>/dev/null
#        kubectl --context="$CONTEXT" get gatewayclass
    done
#    kubectl get pods,service
#    kubectl get gatewayclass
}

# Add your code here:
SHOW_VERBOSE_STUFF="false"
SHOW_GCLOUD_ENTITIES="false"
SHOW_PANTHEON_LINKS="true"
SHOW_KUBERNETES_STUFF="true"

echo "+ REGION for DEPLOY:          $CLOUD_DEPLOY_REGION"
echo "+ REGION for EVERYTHING ELSE: $REGION"

#echo TODO kubectl get pods (TODO first add correct context)
gsutil ls -l "gs://$SKAFFOLD_BUCKET/skaffold-cache/"
kubectl get pods,service
gcloud beta builds triggers list --region $REGION
skaffold config list

if [ "true" = "$SHOW_PANTHEON_LINKS" ]; then 
    echo "== DevConsole useful links START (if you are a UI kind of person) ==" | lolcat
    echo "GKE Workloads: https://console.cloud.google.com/kubernetes/workload/overview?&project=$PROJECT_ID"
    echo "Cloud Build Builds: https://console.cloud.google.com/cloud-build/builds;region=global?&project=$PROJECT_ID"
    echo "Cloud Build Triggers: https://console.cloud.google.com/cloud-build/triggers;region=global?project=$PROJECT_ID"
    echo "Cloud Deploy Pipelines: https://console.cloud.google.com/deploy/delivery-pipelines?project=$PROJECT_ID"
    echo "== DevConsole useful links END =="
fi

if [ "true" = $SHOW_KUBERNETES_STUFF ] ; then
    show_k8s_stuff
fi 

# Docs: https://cloud.google.com/sdk/gcloud/reference/beta/artifacts/docker
if [ "true" = "$SHOW_GCLOUD_ENTITIES" ] ; then
    echo "+ Let's count the images for each artifact:"
    gcloud artifacts docker images list "$ARTIFACT_LONG_REPO_PATH" | awk '{print $1}' | sort | uniq -c
    gcloud deploy delivery-pipelines list | egrep "name:|targetId"
fi 
if [ "true" = "$SHOW_VERBOSE_STUFF" ] ; then
    gsutil ls -l "gs://$SKAFFOLD_BUCKET/skaffold-cache/"
    gcloud beta builds triggers list --region $REGION
    skaffold config list
fi

echo TODO get for both apps/pipelines, for every target the current release similar to https://screenshot.googleplex.com/AuKQWtQsfAvvdsb

# End of your code here
echo Everything is ok.