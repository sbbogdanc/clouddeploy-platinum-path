#!/bin/bash

# Created with codelabba.rb v.1.4a
source .env.sh || fatal "Config doesnt exist please create .env.sh"
set -x
set -e

# Add your code here:

echo "Here we set up a few clusters, cicd-dev/cicd-prod (one for prod and one for everything else). We set up everything in region $REGION" | lolcat
gcloud auth configure-docker $REGION-docker.pkg.dev


##############################################################################
# Create clusters normal (no autopilot since I need to run Daniel crazy code)
##############################################################################
# DEV
GKE_REGION2="europe-north1" # Finland
gcloud container --project "$PROJECT_ID" clusters create "cicd-noauto-dev" --region "$GKE_REGION2" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION2/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" --enable-ip-alias
gcloud container --project "$PROJECT_ID" clusters create "cicd-noauto-canary" --region "$GKE_REGION2" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION2/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" --enable-ip-alias
gcloud container --project "$PROJECT_ID" clusters create "cicd-noauto-prod" --region "$GKE_REGION2" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION2/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" --enable-ip-alias

#############################################################
# Create 3 clusters in autopilot
#############################################################
# CANARY (Similar to prod but smaller)
proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
  gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-canary" --region "$REGION" \
    --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
    --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" # --labels "env=prod"
# PROD
proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-prod" --region "$REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22" # --labels "env=prod"
# DEV
proceed_if_error_matches 'ResponseError: code=409, message=Already exists:' \
gcloud container --project "$PROJECT_ID" clusters create-auto "cicd-dev" --region "$REGION" \
  --release-channel "regular" --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" \
  --cluster-ipv4-cidr "/17" --services-ipv4-cidr "/22"



#############################################################
# Create Artifact Registry
#############################################################

gcloud --project "$PROJECT_ID" artifacts repositories create $ARTIFACT_REPONAME \
    --location="$REGION" --repository-format=docker

# End of your code here. verde script can be found in "palladius/sakura"
echo Everything is ok.