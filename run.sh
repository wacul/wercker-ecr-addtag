#!/bin/sh
set +e


error() { printf "✖ %s\n" "$@"
}
warn() { printf "➜ %s\n" "$@"
}
success() { printf "✔ %s\n" "$@"
}
info() { printf "%s\n" "$@"
}

type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

# Check awscli is installed
if ! type_exists 'aws'; then
  pip install -r $WERCKER_STEP_ROOT/requirements.txt
fi

# Check variables
if [ -z "$WERCKER_ECR_ADDTAG_KEY" ]; then
  error "Please set the 'key' variable"
  exit 1
fi
if [ -z "$WERCKER_ECR_ADDTAG_SECRET" ]; then
  error "Please set the 'secret' variable"
  exit 1
fi
if [ -z "$WERCKER_ECR_ADDTAG_REGION" ]; then
  error "Please set the 'region' variable"
  exit 1
fi
if [ -z "$WERCKER_ECR_ADDTAG_REPOSITORY" ]; then
  error "Please set the 'repository' variable"
  exit 1
fi
if [ -z "$WERCKER_ECR_ADDTAG_AWS_REGISTRY_ID" ]; then
  error "Please set the 'aws-registry-id' variable"
  exit 1
fi
if [ -z "$WERCKER_ECR_ADDTAG_SOURCE_TAG" ]; then
  error "Please set the 'source-tag' variable"
  exit 1
fi
if [ -z "$WERCKER_ECR_ADDTAG_ADD_TAG" ]; then
  error "Please set the 'add-tag' variable"
  exit 1
fi

set -e

export AWS_ACCESS_KEY_ID="${WERCKER_ECR_ADDTAG_KEY}"
export AWS_SECRET_ACCESS_KEY="${WERCKER_ECR_ADDTAG_SECRET}"
export AWS_DEFAULT_REGION="${WERCKER_ECR_ADDTAG_REGION}"

IMAGE_MANIFEST=$(aws ecr batch-get-image --registry-id "${WERCKER_ECR_ADDTAG_AWS_REGISTRY_ID}" --repository-name "${WERCKER_ECR_ADDTAG_REPOSITORY}" --image-ids "imageTag=${WERCKER_ECR_ADDTAG_SOURCE_TAG}" --query images[].imageManifest --output text|head -c -1)
aws ecr put-image --registry-id "${WERCKER_ECR_ADDTAG_AWS_REGISTRY_ID}" --repository-name "${WERCKER_ECR_ADDTAG_REPOSITORY}" --image-tag "${WERCKER_ECR_ADDTAG_ADD_TAG}" --image-manifest "${IMAGE_MANIFEST}"

