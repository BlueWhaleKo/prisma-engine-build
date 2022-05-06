#!/bin/bash
set -e

PROGRAM_NAME=$(basename $0)
PROJECT_ROOT=$(dirname $(dirname $0))

BUILDX_INSTANCE="multi-platform-builder"

IMAGE=$1
DOCKERFILE=$2
PLATFORMS=linux/arm64

function print_usage {
  echo "$0 <Image> <Dockerfile>"
}

function validate_command_line_args {
  if [[ -z "$IMAGE" ]]; then 
    echo "Image is not supplied"
    print_usage
    exit 1
  fi

  if [[ -z "$DOCKERFILE" ]]; then 
    echo "Dockerfile is not supplied"
    print_usage
    exit 1
  fi

  if [[ -z "$PLATFORMS" ]]; then 
    echo "Platform is not supplied"
    print_usage
    exit 1
  fi

  echo "=================================="
  echo "Arguments"
  echo "Image: $IMAGE"
  echo "Dockerfile: $DOCKERFILE"
  echo "Platform: $PLATFORMS"
  echo "=================================="
}

function validate_docker_installed {
  if ! [[ $(command -v docker) ]]; then 
    echo "Docker is not installed. Install docker first"
    exit 1
  fi
}

function setup_buildx_platforms {
  echo "Install buildx platforms"
  docker run --privileged --rm tonistiigi/binfmt --install all > /dev/null
}

function setup_buildx_instance {
  _BUILDX_INSTANCE=$1

  echo "Check buildx instance '$_BUILDX_INSTANCE' is set"

  if [[ $(docker buildx ls | grep $_BUILDX_INSTANCE | grep docker-container | wc -l ) -eq 0 ]]; then
    echo "Create buildx instance '$_BUILDX_INSTANCE'"
    docker buildx create --name=$_BUILDX_INSTANCE --driver=docker-container > /dev/null
    echo "Successfully created buildx instance '$_BUILDX_INSTANCE'"
  else
    echo "Buildx instance $_BUILDX_INSTANCE is ready. Skip..."
  fi
}

function build_and_push_images {
  _BUILDX_INSTANCE=$1
  _PLATFORMS=$2
  _IMAGE=$3
  _DOCKERFILE=$4

  echo "Build and push docker images"
  docker buildx build --builder=$_BUILDX_INSTANCE --platform=$_PLATFORMS --file=$_DOCKERFILE --push -t $_IMAGE .
}

validate_command_line_args
validate_docker_installed
setup_buildx_platforms
setup_buildx_instance $BUILDX_INSTANCE
build_and_push_images $BUILDX_INSTANCE $PLATFORMS $IMAGE $DOCKERFILE