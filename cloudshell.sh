#!/bin/bash

gcloud config set compute/zone us-east1-b

export PROJECT_ID=$(gcloud info --format='value(config.project)')

export BUCKET_NAME="memories-bucket-93202"
export TOPIC_NAME="memories-topic-301"
export CLOUD_FUNCTION_NAME="memories-thumbnail-generator"

gsutil mb -l us-east1 gs://$BUCKET_NAME
gcloud pubsub topics create $TOPIC_NAME

export LASTUSER=$(gcloud projects get-iam-policy $BUCKET_NAME --flatten="bindings[].members" --format='table(bindings.members)' --filter="bindings.members:user:student*" |& tail -1)

gcloud projects remove-iam-policy-binding $BUCKET_NAME --member $LASTUSER --role roles/viewer

cd script-nodejs/

gcloud functions deploy $CLOUD_FUNCTION_NAME --region=us-east1 --trigger-bucket=gs://$BUCKET_NAME --runtime=nodejs12 --entry-point=thumbnail  --quiet

cd ..
gsutil cp map.jpg gs://$BUCKET_NAME/
