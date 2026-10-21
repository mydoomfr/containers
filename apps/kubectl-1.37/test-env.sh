#!/usr/bin/env bash

export KUBECTL_VERSION=$(docker inspect "$GOSS_IMAGE" --format '{{ index .Config.Labels "org.opencontainers.image.version" }}')
export GOSS_RUN_OPTS="--entrypoint=sleep -e KUBECTL_VERSION=${KUBECTL_VERSION}"
export GOSS_RUN_CMD="infinity"
