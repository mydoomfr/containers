FROM debian:trixie-slim@sha256:f6b08b09a05725f9431502d3b5714f5c4576e82c1a84fa1debe0c24a7e0c3ec4

ARG TARGETARCH
ARG VERSION
ARG YQ_VERSION

RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gettext \
        git \
        jq \
        procps \
        bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# yq first: its layer stays cached across kubectl patch bumps.
# The checksums file lists one hash per column, following checksums_hashes_order; SHA-256 is the 18th hash (awk field 19).
RUN ARCH=${TARGETARCH:-amd64} && \
    curl -fsSL --retry 3 "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}" -o /usr/local/bin/yq && \
    curl -fsSL --retry 3 "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/checksums" -o /tmp/yq.checksums && \
    grep "^yq_linux_${ARCH} " /tmp/yq.checksums | awk '{print $19 "  /usr/local/bin/yq"}' | sha256sum -c - && \
    chmod +x /usr/local/bin/yq && \
    rm /tmp/yq.checksums

RUN ARCH=${TARGETARCH:-amd64} && \
    curl -fsSL --retry 3 "https://dl.k8s.io/release/v${VERSION}/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    curl -fsSL --retry 3 "https://dl.k8s.io/release/v${VERSION}/bin/linux/${ARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 && \
    echo "$(cat /tmp/kubectl.sha256)  /usr/local/bin/kubectl" | sha256sum -c - && \
    chmod +x /usr/local/bin/kubectl && \
    rm /tmp/kubectl.sha256

RUN useradd -r -u 1001 -g root kubectl && \
    mkdir -p /.kube && \
    chmod g+rwX /.kube

USER 1001

ENTRYPOINT [ "kubectl" ]
CMD [ "--help" ]
