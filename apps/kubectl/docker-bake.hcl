target "docker-metadata-action" {}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kubernetes/kubernetes versioning=semver extractVersion=^v(?<version>1\.34\..*)$
  default = "1.34.0"
}

function "minor" {
  params = [version]
  result = "${split(".", version)[0]}.${split(".", version)[1]}"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  context = "https://github.com/bitnami/containers.git#main:bitnami/kubectl/${minor(VERSION)}/debian-12"
  dockerfile = "Dockerfile"
  args = {
    VERSION = "${VERSION}"
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
