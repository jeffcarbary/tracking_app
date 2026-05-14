#!/bin/bash
set -e

IMAGE_NAME="jeffcarbary/tracking-api"
TAG=$(git rev-parse --short HEAD)

cp ../backup/.env . 

echo "Loading .env..."
set -a
source .env
set +a

echo "Building image... $IMAGE_NAME:$TAG"
docker build -t $IMAGE_NAME:$TAG .

echo "Pushing image... $IMAGE_NAME:$TAG"
docker push $IMAGE_NAME:$TAG

echo "Applying Postgres secret..."
kubectl create secret generic postgres-secret \
  --from-literal=DATABASE_USER=$DATABASE_USER \
  --from-literal=DATABASE_PASSWORD=$DATABASE_PASSWORD \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Applying Cloudflare secret..."
kubectl create secret generic cloudflare-secret \
  --from-literal=CLOUDFLARE_TOKEN=$CLOUDFLARE_TOKEN \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Updating deployment image...$IMAGE_NAME:$TAG"
kubectl set image deployment/tracking-api \
  api=$IMAGE_NAME:$TAG

echo "Waiting for rollout..."
kubectl rollout status deployment/tracking-api

echo "Done."
