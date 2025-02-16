#!/bin/bash

# Stops script execution if a command has an error
set -e

# set default build args if not provided
BUILD_ARGS="$INPUT_BUILD_ARGS"
if [ -z "$BUILD_ARGS" ]; then
    BUILD_ARGS="--check --make --test"
fi

if [ -n "$GITHUB_TOKEN" ]; then
    echo "GitHub Token provided. Setting up GitHub URLs..."
    # Use the github token to authenticate the git interaction (see this Stackoverflow answer: https://stackoverflow.com/a/57229018/5379273)
    git config --global url."https://api:$GITHUB_TOKEN@github.com/".insteadOf "https://github.com/"
    git config --global url."https://ssh:$GITHUB_TOKEN@github.com/".insteadOf "ssh://git@github.com/"
    git config --global url."https://git:$GITHUB_TOKEN@github.com/".insteadOf "git@github.com:"

    BUILD_ARGS="$BUILD_ARGS --github-token=$GITHUB_TOKEN"
fi

if [ -n "$INPUT_CONTAINER_REGISTRY_USERNAME" ] && [ -n "$INPUT_CONTAINER_REGISTRY_PASSWORD" ]; then
    echo "Container registry credentials provided. Logging in to registry..."
    docker login $INPUT_CONTAINER_REGISTRY_URL -u "$INPUT_CONTAINER_REGISTRY_USERNAME" -p "$INPUT_CONTAINER_REGISTRY_PASSWORD"

    if [ -n "$INPUT_CONTAINER_REGISTRY_URL" ]; then
        BUILD_ARGS="$BUILD_ARGS --container-registry-url=$INPUT_CONTAINER_REGISTRY_URL"
    fi

    BUILD_ARGS="$BUILD_ARGS --container-registry-username=$INPUT_CONTAINER_REGISTRY_USERNAME"
    BUILD_ARGS="$BUILD_ARGS --container-registry-password=$INPUT_CONTAINER_REGISTRY_PASSWORD"
fi

# Navigate to working directory, if provided
if [ -n "$INPUT_WORKING_DIRECTORY" ]; then
    cd "$INPUT_WORKING_DIRECTORY"
else
    cd "$GITHUB_WORKSPACE"
fi

# Get docker mount directory either via volume or bind mount
INPUT_CONTAINER_MOUNT=$(echo $(docker inspect $(basename "$(cat /proc/1/cpuset)") | jq -r '.[0].HostConfig.Binds[]| select(. | contains("/github/workspace"))') | sed 's/:.*//')
if [ -z "$INPUT_CONTAINER_MOUNT" ]; then
    INPUT_CONTAINER_MOUNT=$(docker inspect $(basename "$(cat /proc/1/cpuset)") | jq -r '.[0].HostConfig.Mounts[]|select(.Target=="/github").Source')
fi
export INPUT_CONTAINER_MOUNT

if [ -n "$INPUT_CONTAINER_MOUNT" ]; then
    BUILD_ARGS="$BUILD_ARGS --container-mount=\"$INPUT_CONTAINER_MOUNT\""
fi

# Set Python version if provided
if [ -n "$INPUT_PYTHON_VERSION" ]; then
    export PYTHON_VERSION="$INPUT_PYTHON_VERSION"
    echo "Python version specified: $PYTHON_VERSION"
    pyenv install -s $PYTHON_VERSION
    pyenv global $PYTHON_VERSION
fi

# Print command
set -x

# Execute build script
python -u build.py $BUILD_ARGS
