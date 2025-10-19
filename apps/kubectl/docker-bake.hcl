target "docker-metadata-action" {}

variable "KUBECTL_1_33_VERSION" {
  // renovate: datasource=github-releases depName=kubernetes/kubernetes versioning=semver extractVersion=^v(?<version>1\.33\..+)$
  default = "1.33.7"
}

variable "KUBECTL_1_34_VERSION" {
  // renovate: datasource=github-releases depName=kubernetes/kubernetes versioning=semver extractVersion=^v(?<version>1\.34\..+)$
  default = "1.34.1"
}

function "major_minor" {
  params = [version]
  result = "${split(".", version)[0]}.${split(".", version)[1]}"
}

group "default" {
  targets = ["image-local"]
}

target "image-1-33" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    KUBECTL_VERSION = "${KUBECTL_1_33_VERSION}"
  }
  tags = [
    "kubectl:${KUBECTL_1_33_VERSION}",
    "kubectl:${major_minor(KUBECTL_1_33_VERSION)}"
  ]
}

target "image-1-34" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    KUBECTL_VERSION = "${KUBECTL_1_34_VERSION}"
  }
  tags = [
    "kubectl:${KUBECTL_1_34_VERSION}",
    "kubectl:${major_minor(KUBECTL_1_34_VERSION)}",
    "kubectl:latest"
  ]
}

target "image-local" {
  inherits = ["image-1-34"]
  output = ["type=docker"]
}

target "image" {
  inherits = ["image-1-33", "image-1-34"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
