#!/bin/bash
export VERSION=$(docker buildx bake --file ./apps/kubectl/docker-bake.hcl --print image 2>/dev/null | jq -r '.target.image.args.VERSION')
export GOSS_RUN_OPTS="--entrypoint /bin/sleep -e VERSION=${VERSION}"
export GOSS_RUN_CMD="infinity"
