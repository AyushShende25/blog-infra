#!/bin/bash
REGION="ap-south-1"
ECR_REGISTRY="651447471372.dkr.ecr.${REGION}.amazonaws.com"
APP_DIR="/opt/inkspire"

mkdir -p "${APP_DIR}"

aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

IMAGE_TAG=$(aws ssm get-parameter \
    --region "${REGION}" \
    --name "/inkspire/image" \
    --query "Parameter.Value" \
    --output text)
            
docker pull "${ECR_REGISTRY}/inkspire-backend:${IMAGE_TAG}"

PARAMS=$(aws ssm get-parameters-by-path \
    --region "${REGION}" \
    --path "/inkspire/prod" \
    --recursive \
    --with-decryption)

echo "$PARAMS" \
| jq -r '.Parameters[] | "\(.Name | split("/")[-1])=\(.Value)"' \
>> "${APP_DIR}/.env"

docker rm -f inkspire-worker || true

docker run -d \
    --name inkspire-worker \
    --restart unless-stopped \
    --env-file "${APP_DIR}/.env" \
    "${ECR_REGISTRY}/inkspire-backend:${IMAGE_TAG}" node dist/worker.js