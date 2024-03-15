#!/bin/sh

# ==============================================================================
# Aliases for `cd`.
# ==============================================================================

# Build an image and immediately run a container in the background from it.
# Requires a Dockerfile in the current directory.
# Optionally pass a name for the image (else one will be automatically created).
#
# Reference: https://stackoverflow.com/questions/36075525/
#
runDockerFromFile() {
  if [ -z "$1" ]; then
    docker run --detach "$(docker build -q .)"
  else
    docker build --tag "$1" .
    docker run --detach "$1"
  fi
}

listDockerImages() {
  docker image ls
}
