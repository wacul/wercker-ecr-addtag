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

# Check pip is installed
if ! type_exists 'pip'; then
  if type_exists 'curl'; then
    curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python2.7
  elif type_exists 'wget' && type_exists 'openssl'; then
    wget -q -O - https://bootstrap.pypa.io/get-pip.py | sudo python2.7
  else
    error "Please install pip, curl, or wget with openssl"
    exit 1
  fi
fi

# Install python dependencies
INSTALL_DEPENDENCIES=$(pip install -r $WERCKER_STEP_ROOT/requirements.txt 2>&1)
if [ $? -ne 0 ]; then
  error "Unable to install dependencies"
  warn "$INSTALL_DEPENDENCIES"
  exit 1
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

export AWS_ACCESS_KEY_ID="${WERCKER_ECR_ADDTAG_KEY}"
export AWS_SECRET_ACCESS_KEY="${WERCKER_ECR_ADDTAG_SECRET}"
export AWS_DEFAULT_REGION="${WERCKER_ECR_ADDTAG_REGION}"

# ecr docker login
$(aws ecr get-login --no-include-email --region us-east-1)
TEMP_FILE=$(mktemp)
aws ecr batch-get-image --registryId "${WERCKER_ECR_ADDTAG_AWS_REGISTRY_ID}" --repository-name "${WERCKER_ECR_ADDTAG_REPOSITORY}" --image-ids "imageTag=${WERCKER_ECR_ADDTAG_SOURCE_TAG}" --query images[].imageManifest --output text > "${TEMP_FILE}"
aws ecr put-image --repository-name "${WERCKER_ECR_ADDTAG_AWS_REGISTRY_ID}" --image-tag "${WERCKER_ECR_ADDTAG_ADD_TAG}" --image-manifest "file://${TEMP_FILE}"

