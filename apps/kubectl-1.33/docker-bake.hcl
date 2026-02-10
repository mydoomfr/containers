target "docker-metadata-action" {}

variable "IMAGE_NAME" {
  default = "kubectl"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kubernetes/kubernetes versioning=semver extractVersion=^v(?<version>1\.33\.\d+)$
  default = "1.33.8"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    KUBECTL_VERSION = "${VERSION}"
    VERSION = "${VERSION}"
    IMAGE_NAME = "${IMAGE_NAME}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
