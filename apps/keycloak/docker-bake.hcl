target "docker-metadata-action" {}

variable "VERSION" {
  // renovate: datasource=github-releases depName=keycloak/keycloak versioning=semver
  default = "26.4.5"
}

function "major" {
  params = [version]
  result = split(".", version)[0]
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  context = "https://github.com/bitnami/containers.git#main:bitnami/keycloak/${major(VERSION)}/debian-12"
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
